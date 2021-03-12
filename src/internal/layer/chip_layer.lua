local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")
local UiTheme = require("api.gui.UiTheme")
local atlas = require("internal.draw.atlas")
local atlases = require("internal.global.atlases")

local chip_layer = class.class("chip_layer", IDrawLayer)

function chip_layer:init(width, height)
   self.width = width
   self.height = height
   self.chip_batch = sparse_batch:new(self.width, self.height)
   self.shadow_batch = sparse_batch:new(self.width, self.height)
   self.drop_shadow_batch = sparse_batch:new(self.width, self.height)

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

function chip_layer:on_theme_switched(coords)
   local chip_atlas = atlases.get().chip
   local item_shadow_atlas = atlases.get().item_shadow

   local shadow_atlas = atlas:new(48, 48)
   self.t = UiTheme.load(self)

   local tiles = {{
         _id = "shadow",
         image = self.t.base.character_shadow
   }}
   shadow_atlas:load(tiles, coords)

   self.chip_batch:on_theme_switched(chip_atlas, coords)
   self.shadow_batch:on_theme_switched(shadow_atlas, coords)
   self.drop_shadow_batch:on_theme_switched(item_shadow_atlas, coords)
end

function chip_layer:relayout()
   self.t = UiTheme.load(self)
end

function chip_layer:reset()
   self.chip_batch_inds = {}
   self.shadow_batch_inds = {}
   self.drop_shadow_batch_inds = {}
end
local it = 0

function chip_layer:draw_drop_shadow(i, x, y, y_offset)
   local batch_ind = self.shadow_batch_inds[i.uid]
   local image = i.image
   local x_offset = i.x_offset
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
      y_offset = y_offset - 4
      rotation = rotation / 2
   else
      if (i.y_offset or 0) < self.chip_batch.tile_height / 2 then
         x_offset = (i.x_offset or 0) + rotation / 80 + 2
         y_offset = y_offset - 2
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

local CONFIG = {
   ["base.chara"] = {
      z_order = 3,
      y_offset = -16
   },
   ["base.item"] = {
      z_order = 2,
      y_offset = 0,
      show_memory = true,
      is_stacking = true
   },
   ["base.mef"] = {
      z_order = 1,
      y_offset = 0,
      show_memory = true
   },
   ["base.feat"] = {
      z_order = 0,
      y_offset = 0,
      show_memory = true
   }
}

local TYPES = table.keys(CONFIG)

function chip_layer:draw_one(ind, x, y, i, chip_type, stack_height)
   local shadow_type = i.shadow_type
   local batch_ind = self.chip_batch_inds[i.uid]
   local image = i.drawable or i.image
   local x_offset = i.x_offset or 0
   local y_offset_base = CONFIG[chip_type].y_offset
   local y_offset = (i.y_offset or 0) + y_offset_base - (stack_height or 0)
   if batch_ind == nil or batch_ind == 0 then
      -- tiles at the top of the screen should be drawn
      -- first, so they have the lowest z-order. conveniently
      -- this is already representable by tile indices since
      -- index 0 represents (0, 0), 1 represents (1, 0), and
      -- so on.
      local z_order = ind + CONFIG[chip_type].z_order

      local new_ind = self.chip_batch:add_tile {
         tile = image,
         x = x,
         y = y,
         x_offset = x_offset,
         y_offset = y_offset,
         color = i.color,
         z_order = z_order,
         drawables = i.drawables,
         drawables_after = i.drawables_after,
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
      self:draw_drop_shadow(i, x, y, y_offset)
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

function chip_layer:draw_normal(ind, map, stack, chip_type, found)
   local x = (ind-1) % map:width()
   local y = math.floor((ind-1) / map:width())

   for _, i in ipairs(stack) do
      if i.uid then
         found[i.uid] = true

         local show = i.show
         if not map:is_in_fov(x, y) then
            show = show and CONFIG[chip_type].show_memory
         end

         if show then
            self:draw_one(ind, x, y, i, chip_type)
         end
      end
   end
end

function chip_layer:draw_stacking(ind, map, stack, chip_type, found)
   local x = (ind-1) % map:width()
   local y = math.floor((ind-1) / map:width())

   local show_count = 0
   local to_show = {}
   local first
   for _, i in ipairs(stack) do
      if i.uid then
         first = first or i
         local show = i.show
         if not map:is_in_fov(x, y) then
            show = show and CONFIG[chip_type].show_memory
         end
         if show then
            to_show[i] = show
            show_count = show_count + 1
         end
      end
   end

   if show_count > 3 then
      -- HACK
      local i = {
         uid = first.uid,
         show = true,
         image = "elona.item_stack",
         color = {255, 255, 255},
         x_offset = 0,
         y_offset = 0,
         shadow_type = "drop_shadow"
      }
      self:draw_one(ind, x, y, i, chip_type, 0)
   else
      local stack_height = 0
      for _, i in ipairs(stack) do
         if i.uid then
            found[i.uid] = true

            if to_show[i] then
               self:draw_one(ind, x, y, i, chip_type, stack_height)
               stack_height = stack_height + i.stack_height
            end
         end
      end
   end
end

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

   self.chip_batch:clear()
   self.shadow_batch:clear()
   self.drop_shadow_batch:clear()

   self.chip_batch_inds = {}
   self.shadow_batch_inds = {}
   self.drop_shadow_batch_inds = {}

   for _, chip_type in ipairs(TYPES) do
      for ind, stack in map:iter_memory(chip_type) do
         if CONFIG[chip_type].is_stacking then
            self:draw_stacking(ind, map, stack, chip_type, found)
         else
            self:draw_normal(ind, map, stack, chip_type, found)
         end
      end
   end

   it = it + 1

   for uid, _ in pairs(self.chip_batch_inds) do
      if not found[uid] then
         local chip_uid = self.chip_batch_inds[uid]
         if chip_uid then
            self.chip_batch:remove_tile(chip_uid)
         end
         local shadow_uid = self.shadow_batch_inds[uid]
         if shadow_uid then
            self.shadow_batch:remove_tile(shadow_uid)
         end
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
            self["i_" .. ind.hp_bar] = self.t.base[ind.hp_bar]:make_instance()
         end

         local ratio = math.clamp(ind.hp_ratio or 1.0, 0.0, 1.0)
         self["i_" .. ind.hp_bar]:draw_percentage_bar(sx - draw_x + offx + ind.x * 48 + 9,
                                                      sy - draw_y + offy + ind.y * 48 + CONFIG["base.chara"].y_offset + 48,
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
