local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local Gui = require("api.Gui")
local UiTheme = require("api.gui.UiTheme")
local sparse_batch = require("internal.draw.sparse_batch")
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

function chip_layer:default_z_order()
   return Gui.LAYER_Z_ORDER_TILEMAP + 30000
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

function chip_layer:draw_drop_shadow(index, i, x, y, y_offset)
   local batch_ind = self.shadow_batch_inds[index]
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
         self.drop_shadow_batch_inds[index] = self.drop_shadow_batch:add_tile(index, {
            tile = image,
            x = x,
            y = y,
            x_offset = x_offset,
            y_offset = y_offset,
            rotation = math.rad(rotation),
            z_order = 0,
         })
      else
         self.drop_shadow_batch.xcoords[index] = x
         self.drop_shadow_batch.ycoords[index] = y
         self.drop_shadow_batch.xoffs[index] = x_offset
         self.drop_shadow_batch.yoffs[index] = y_offset
         self.drop_shadow_batch.rotations[index] = rotation
      end
   else
      self.drop_shadow_batch:remove_tile(index)
      self.drop_shadow_batch_inds[index] = nil
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

function chip_layer:draw_one(index, ind, x, y, i, chip_type, stack_height)
   local shadow_type = i.shadow_type
   local batch_ind = self.chip_batch_inds[index]
   local image = i.drawable or i.image
   local x_offset = i.x_offset or 0
   local y_offset_base = CONFIG[chip_type].y_offset
   local y_offset = (i.y_offset or 0) + y_offset_base - (stack_height or 0)
   if batch_ind == nil then
      -- tiles at the top of the screen should be drawn
      -- first, so they have the lowest z-order. conveniently
      -- this is already representable by tile indices since
      -- index 0 represents (0, 0), 1 represents (1, 0), and
      -- so on.
      local z_order = ind + CONFIG[chip_type].z_order

      self.chip_batch:add_tile(index, {
         tile = image,
         x = x,
         y = y,
         x_offset = x_offset,
         y_offset = y_offset,
         color = i.color,
         z_order = z_order,
         drawables = i.drawables,
         drawables_after = i.drawables_after,
      })

      -- Extra data needed for rendering non-chip things like
      -- the HP bar.
      self.chip_batch_inds[index] = {
         ind = index,
         x = x,
         y = y,
         y_offset = y_offset,
         hp_ratio = i.hp_ratio,
         hp_bar = i.hp_bar
      }
   else
      self.chip_batch.tiles[index] = image
      self.chip_batch.xcoords[index] = x
      self.chip_batch.ycoords[index] = y
      self.chip_batch.xoffs[index] = x_offset
      self.chip_batch.yoffs[index] = y_offset
      if i.color then
         self.chip_batch.colors_r[index] = (i.color[1] or 255) / 255
         self.chip_batch.colors_g[index] = (i.color[2] or 255) / 255
         self.chip_batch.colors_b[index] = (i.color[3] or 255) / 255
      else
         self.chip_batch.colors_r[index] = 1
         self.chip_batch.colors_g[index] = 1
         self.chip_batch.colors_b[index] = 1
      end
      self.chip_batch.drawables[index] = i.drawables
      self.chip_batch.drawables_after[index] = i.drawables_after

      batch_ind.x = x
      batch_ind.y = y
      batch_ind.y_offset = y_offset
      batch_ind.hp_ratio = i.hp_ratio
      batch_ind.hp_bar = i.hp_bar
   end

   if shadow_type == "drop_shadow" then
      --
      -- Item drop shadow.
      --
      self:draw_drop_shadow(index, i, x, y, y_offset)
   elseif shadow_type == "normal" then
      if self.shadow_batch_inds[index] then
         self.shadow_batch.xcoords[index] = x
         self.shadow_batch.ycoords[index] = y
         self.shadow_batch.yoffs[index] = y_offset

         batch_ind.x = x
         batch_ind.y = y
         batch_ind.y_offset = y_offset
         batch_ind.hp_ratio = i.hp_ratio
         batch_ind.hp_bar = i.hp_bar
      else
         self.shadow_batch:add_tile(index, {
            tile = "shadow",
            x = x,
            y = y,
            y_offset = y_offset,
            z_order = 0
         })
         self.shadow_batch_inds[index] = { ind = index, x = x, y = y }
      end
   end
end

function chip_layer:draw_normal(index, ind, map, mem, chip_type)
   local x = (ind-1) % map:width()
   local y = math.floor((ind-1) / map:width())

   local show = mem.show
   if not map:is_in_fov(x, y) then
      show = show and CONFIG[chip_type].show_memory
   end

   if show then
      self:draw_one(index, ind, x, y, mem, chip_type)
   end
end

function chip_layer:update(map, dt, screen_updated, scroll_frames)
   self.chip_batch:update(dt)
   self.drop_shadow_batch:update(dt)

   if not screen_updated then return end

   if scroll_frames > 0 then
      return true
   end

   assert(map ~= nil)

   local found = {}

   print(table.count(map._object_memory_dirty))
   for index, _ in pairs(map._object_memory_dirty) do
      local mem = map._object_memory[index]
      if mem then
         local ind = map._object_memory_pos[index]
         local chip_type = mem._type
         self:draw_normal(index, ind, map, mem, chip_type, found)
      else
         self.chip_batch_inds[index] = nil
         self.shadow_batch_inds[index] = nil
         self.drop_shadow_batch_inds[index] = nil

         self.chip_batch:remove_tile(index)
         self.shadow_batch:remove_tile(index)
         self.drop_shadow_batch:remove_tile(index)
      end
   end
   table.clear(map._object_memory_dirty)

   -- for uid, _ in pairs(self.chip_batch_inds) do
   --    if not found[uid] then
   --       local chip_uid = self.chip_batch_inds[uid]
   --       if chip_uid then
   --          self.chip_batch:remove_tile(chip_uid)
   --       end
   --       local shadow_uid = self.shadow_batch_inds[uid]
   --       if shadow_uid then
   --          self.shadow_batch:remove_tile(shadow_uid)
   --       end
   --       self.chip_batch_inds[uid] = nil
   --       self.shadow_batch_inds[uid] = nil
   --    end
   -- end
end

function chip_layer:draw_hp_bars(draw_x, draw_y, offx, offy)
   -- TODO: rewrite this as a batched draw layer
   for _, ind in pairs(self.chip_batch_inds) do
      if ind.hp_bar then
         if self["i_" .. ind.hp_bar] == nil then
            self["i_" .. ind.hp_bar] = self.t.base[ind.hp_bar]:make_instance()
         end

         local ratio = math.clamp(ind.hp_ratio or 1.0, 0.0, 1.0)
         self["i_" .. ind.hp_bar]:draw_percentage_bar(draw_x + offx + ind.x * 48 + 9,
                                                      draw_y + offy + ind.y * 48 + CONFIG["base.chara"].y_offset + 48,
                                                      ratio * 30)
      end
   end
end

function chip_layer:draw(draw_x, draw_y, width, height)
   local offx, offy = 0, 0
   love.graphics.setShader(self.shadow_shader)
   Draw.set_color(255, 255, 255, 80)
   Draw.set_blend_mode("subtract")
   self.drop_shadow_batch:draw(draw_x, draw_y, width, height)
   love.graphics.setShader()

   Draw.set_blend_mode("subtract")
   Draw.set_color(255, 255, 255, 110)
   self.shadow_batch:draw(draw_x + 8, draw_y + 36, width, height)

   Draw.set_color(255, 255, 255)
   Draw.set_blend_mode("alpha")
   self.chip_batch:draw(draw_x, draw_y, width, height)

   self:draw_hp_bars(draw_x, draw_y, offx, offy)
end

return chip_layer
