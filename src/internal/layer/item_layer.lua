local Map = require("api.Map")
local Item = require("api.Item")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")

local item_layer = class.class("item_layer", IDrawLayer)

function item_layer:init(width, height)
   local coords = Draw.get_coords()
   local item_atlas = require("internal.global.atlases").get().item
   local item_shadow_atlas = require("internal.global.atlases").get().item_shadow

   self.item_batch = sparse_batch:new(width, height, item_atlas, coords)
   self.shadow_batch = sparse_batch:new(width, height, item_shadow_atlas, coords)
   self.batch_inds = {}
   self.shadow_batch_inds = {}

   self.shader = love.graphics.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 textureColor = Texel(tex, texture_coords);
    return vec4(1, 1, 1, textureColor.a * color.a);
}
]])
end

function item_layer:relayout()
end

function item_layer:reset()
   self.batch_inds = {}
end
local it = 0

function item_layer:update(dt, screen_updated, scroll_frames)
   if not screen_updated then return end

   self.item_batch.updated = true
   self.shadow_batch.updated = true

   if scroll_frames > 0 then
      return true
   end

   local map = Map.current()
   assert(map ~= nil)

   local found = {}

   for ind, stack in map:iter_memory("base.item") do
      local x = (ind-1) % map:width()
      local y = math.floor((ind-1) / map:width())
      for _, i in ipairs(stack) do
         found[i.uid] = true
         local show = i.show
         local hide = not show
            and self.batch_inds[i.uid] ~= nil
            and self.batch_inds[i.uid] ~= 0

         if show then
            --
            -- Item chip.
            --
            local batch_ind = self.batch_inds[i.uid]
            local image = i.image
            local x_offset = i.x_offset
            local y_offset = i.y_offset
            if batch_ind == nil or batch_ind == 0 then
               self.batch_inds[i.uid] = self.item_batch:add_tile {
                  tile = image,
                  x = x,
                  y = y,
                  x_offset = x_offset,
                  y_offset = y_offset,
               }
            else
               local tile, px, py = self.item_batch:get_tile(batch_ind)

               if px ~= x or py ~= i or tile ~= image then
                  self.item_batch:remove_tile(batch_ind)
                  self.batch_inds[i.uid] = self.item_batch:add_tile {
                     tile = image,
                     x = x,
                     y = y,
                     x_offset = x_offset,
                     y_offset = y_offset,
                  }
               end
            end


            --
            -- Item drop shadow.
            --
            batch_ind = self.shadow_batch_inds[i.uid]
            image = i.image
            x_offset = i.x_offset
            y_offset = i.y_offset
            local rotation = i.shadow or 20

            local draw = true
            local image_data = self.item_batch.atlas.tiles[image]
            local is_tall = false
            if image_data then
               local _, _, tw, th = image_data.quad:getViewport()
               is_tall = tw * 2 == th
            end

            if is_tall then
               x_offset = i.x_offset + rotation / 2
               y_offset = i.y_offset - 4
               rotation = rotation / 4
            else
               if i.y_offset < self.item_batch.tile_height / 2 then
                  x_offset = i.x_offset + rotation / 80 + 2
                  y_offset = i.y_offset - 2
                  rotation = rotation / 4
               else
                  draw = false
               end
            end

            if draw then
               if batch_ind == nil or batch_ind == 0 then
                  self.shadow_batch_inds[i.uid] = self.shadow_batch:add_tile {
                     tile = image,
                     x = x,
                     y = y,
                     x_offset = x_offset,
                     y_offset = y_offset,
                     rotation = math.rad(rotation)
                  }
               else
                  local tile, px, py = self.shadow_batch:get_tile(batch_ind)

                  if px ~= x or py ~= i or tile ~= image then
                     self.shadow_batch:remove_tile(batch_ind)
                     self.shadow_batch_inds[i.uid] = self.shadow_batch:add_tile {
                        tile = image,
                        x = x,
                        y = y,
                        x_offset = x_offset,
                        y_offset = y_offset,
                        rotation = math.rad(rotation)
                     }
                  end
               end
            else
               self.shadow_batch:remove_tile(self.shadow_batch_inds[i.uid])
               self.shadow_batch_inds[i.uid] = 0
            end
         elseif hide then
            self.item_batch:remove_tile(self.batch_inds[i.uid])
            self.shadow_batch:remove_tile(self.shadow_batch_inds[i.uid])
            self.batch_inds[i.uid] = 0
            self.shadow_batch_inds[i.uid] = 0
         end
      end
   end

   it = it + 1

   for uid, _ in pairs(self.batch_inds) do
      if not found[uid] then
         self.item_batch:remove_tile(self.batch_inds[uid])
         self.shadow_batch:remove_tile(self.shadow_batch_inds[uid])
         self.batch_inds[uid] = nil
         self.shadow_batch_inds[uid] = nil
      end
   end
end

function item_layer:draw(draw_x, draw_y, offx, offy)
   love.graphics.setShader(self.shader)
   Draw.set_color(255, 255, 255, 80)
   love.graphics.setBlendMode("subtract")
   self.shadow_batch:draw(draw_x + offx, draw_y + offy)
   love.graphics.setShader()
   Draw.set_color(255, 255, 255)
   love.graphics.setBlendMode("alpha")
   self.item_batch:draw(draw_x + offx, draw_y + offy)
end

return item_layer
