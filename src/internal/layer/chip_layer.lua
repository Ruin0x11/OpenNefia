local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")
local UiTheme = require("api.gui.UiTheme")
local atlas = require("internal.draw.atlas")
local atlases = require("internal.global.atlases")

local chip_layer = class.class("chip_layer", IDrawLayer)

function chip_layer:init(width, height)
   local coords = Draw.get_coords()
   local chip_atlas = atlases.get().chip
   local item_shadow_atlas = atlases.get().item_shadow

   local shadow_atlas = atlas:new(48, 48)
   self.t = UiTheme.load(self)

   local tiles = {{
         _id = "shadow",
         image = self.t.character_shadow
   }}
   shadow_atlas:load(tiles, coords)

   self.chip_batch = sparse_batch:new(width, height, chip_atlas, coords)
   self.shadow_batch = sparse_batch:new(width, height, shadow_atlas, coords)
   self.drop_shadow_batch = sparse_batch:new(width, height, item_shadow_atlas, coords)
   self.chip_batch_inds = {}
   self.shadow_batch_inds = {}
   self.drop_shadow_batch_inds = {}

   self.shadow_shader = love.graphics.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 textureColor = Texel(tex, texture_coords);
    return vec4(1, 1, 1, textureColor.a * color.a);
}
]])
end

function chip_layer:relayout()
   self.t = UiTheme.load(self)
end

function chip_layer:reset()
   self.chip_batch_inds = {}
end
local it = 0

function chip_layer:draw_drop_shadow(i, x, y)
   local batch_ind = self.shadow_batch_inds[i.uid]
   local image = i.image
   local x_offset = i.x_offset
   local y_offset = i.y_offset
   local rotation = i.shadow_angle or 20

   local draw = true
   local image_data = self.chip_batch.atlas.tiles[image]
   local is_tall = false
   if image_data then
      local _, _, tw, th = image_data.quad:getViewport()
      is_tall = tw * 2 == th
   end

   -- TODO no idea what the rotation amounts should be
   if is_tall then
      x_offset = i.x_offset + rotation / 2
      y_offset = i.y_offset - 4
      rotation = rotation / 2
   else
      if i.y_offset < self.chip_batch.tile_height / 2 then
         x_offset = i.x_offset + rotation / 80 + 2
         y_offset = i.y_offset - 2
         rotation = rotation / 16
      else
         draw = false
      end
   end

   if draw then
      if batch_ind == nil or batch_ind == 0 then
         self.drop_shadow_batch_inds[i.uid] = self.drop_shadow_batch:add_tile {
            tile = image,
            x = x,
            y = y,
            x_offset = x_offset,
            y_offset = y_offset,
            rotation = math.rad(rotation),
            z_order = 0,
         }
      else
         -- local tile, px, py = self.drop_shadow_batch:get_tile(batch_ind)

         -- if px ~= x or py ~= i or tile ~= image then
         --    self.drop_shadow_batch:remove_tile(batch_ind)
         --    self.drop_shadow_batch_inds[i.uid] = self.drop_shadow_batch:add_tile {
         --       tile = image,
         --       x = x,
         --       y = y,
         --       x_offset = x_offset,
         --       y_offset = y_offset,
         --       rotation = math.rad(rotation)
         --    }
         -- end
      end
   else
      self.drop_shadow_batch:remove_tile(self.drop_shadow_batch_inds[i.uid])
      self.drop_shadow_batch_inds[i.uid] = 0
   end
end

local TYPES = {
   "base.chara",
   "base.item",
   "base.feat"
}
local LAYER_Z_ORDER = {
   ["base.chara"] = 2,
   ["base.item"] = 1,
   ["base.feat"] = 0
}
local LAYER_OFFSET_Y = {
   ["base.chara"] = -16,
   ["base.item"] = 0,
   ["base.feat"] = 0
}

local FRAME_LENGTH = 10

function chip_layer:update(dt, screen_updated, scroll_frames)
   self.chip_batch:update(dt)
   self.drop_shadow_batch:update(dt)

   if not screen_updated then return end

   self.chip_batch.updated = true
   self.shadow_batch.updated = true
   self.drop_shadow_batch.updated = true

   if scroll_frames > 0 then
      return true
   end

   local map = Map.current()
   assert(map ~= nil)

   local found = {}

   local all = fun.iter(TYPES)
      :map(function(ty)
             return map:iter_memory(ty)
           end)
      :to_list()

   self.chip_batch:clear()
   self.shadow_batch:clear()
   self.drop_shadow_batch:clear()

   self.chip_batch_inds = {}
   self.shadow_batch_inds = {}
   self.drop_shadow_batch_inds = {}

   for ind, stack in fun.chain(table.unpack(all)) do
      -- { 1, 600 } -> 600
      local chip_type = TYPES[ind[1]]
      ind = ind[2]

      local x = (ind-1) % map:width()
      local y = math.floor((ind-1) / map:width())
      for _, i in ipairs(stack) do
         found[i.uid] = true
         local show = i.show and map:is_in_fov(x, y)
         local shadow_type = i.shadow_type

         if show then
            --
            -- Normal chip.
            --
            local batch_ind = self.chip_batch_inds[i.uid]
            local image = i.drawable or i.image
            local x_offset = i.x_offset or 0
            local y_offset = i.y_offset or 0 + LAYER_OFFSET_Y[chip_type]
            if batch_ind == nil or batch_ind == 0 then
               -- tiles at the top of the screen should be drawn
               -- first, so they have the lowest z-order. conveniently
               -- this is already representable by tile indices since
               -- index 0 represents (0, 0), 1 represents (1, 0), and
               -- so on.
               local z_order = ind + LAYER_Z_ORDER[chip_type]

               local new_ind = self.chip_batch:add_tile {
                  tile = image,
                  x = x,
                  y = y,
                  x_offset = x_offset,
                  y_offset = y_offset,
                  color = i.color,
                  z_order = z_order,
                  drawables = i.drawables
               }

               -- Extra data needed for rendering non-chip things like
               -- the HP bar.
               self.chip_batch_inds[i.uid] = {
                  ind = new_ind,
                  x = x,
                  y = y,
                  y_offset = y_offset,
                  hp_ratio = i.hp_ratio,
                  hp_bar = i.hp_bar
               }
            end

            if shadow_type == "drop_shadow" then
               --
               -- Item drop shadow.
               --
               self:draw_drop_shadow(i, x, y)
            elseif shadow_type == "normal" then
               self.shadow_batch:add_tile {
                  tile = "shadow",
                  x = x,
                  y = y,
                  y_offset = y_offset,
                  z_order = 0
               }
               self.shadow_batch_inds[i] = { ind = ind, x = x, y = y }
            end
         end
      end
   end

   it = it + 1

   for uid, _ in pairs(self.chip_batch_inds) do
      if not found[uid] then
         self.chip_batch:remove_tile(self.chip_batch_inds[uid])
         self.shadow_batch:remove_tile(self.shadow_batch_inds[uid])
         self.chip_batch_inds[uid] = nil
         self.shadow_batch_inds[uid] = nil
      end
   end
end

function chip_layer:draw_hp_bars(draw_x, draw_y, offx, offy)
   local sx, sy = Draw.get_coords():get_start_offset(draw_x, draw_y)

   -- TODO: rewrite this as a batched draw layer
   for _, ind in pairs(self.chip_batch_inds) do
      if ind.hp_bar then
         if self["i_" .. ind.hp_bar] == nil then
            self["i_" .. ind.hp_bar] = self.t[ind.hp_bar]:make_instance()
         end

         local ratio = ind.hp_ratio or 0.9
         self["i_" .. ind.hp_bar]:draw_percentage_bar(sx - draw_x + offx + ind.x * 48 + 9,
                                                      sy - draw_y + offy + ind.y * 48 + ind.y_offset + 48,
                                                      ratio * 30, 3, ratio * 30)
      end
   end
end

function chip_layer:draw(draw_x, draw_y, offx, offy)
   love.graphics.setShader(self.shadow_shader)
   Draw.set_color(255, 255, 255, 80)
   Draw.set_blend_mode("subtract")
   self.drop_shadow_batch:draw(draw_x + offx, draw_y + offy)
   love.graphics.setShader()

   Draw.set_blend_mode("subtract")
   Draw.set_color(255, 255, 255, 110)
   self.shadow_batch:draw(draw_x + offx, draw_y + offy, 8, 36)

   Draw.set_color(255, 255, 255)
   Draw.set_blend_mode("alpha")
   self.chip_batch:draw(draw_x + offx, draw_y + offy)

   self:draw_hp_bars(draw_x, draw_y, offx, offy)
end

return chip_layer
