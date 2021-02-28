local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local tile_batch = require("internal.draw.tile_batch")
local save = require("internal.global.save")
local atlases = require("internal.global.atlases")
local iso_coords = require("internal.draw.coords.iso_coords")

local tile_overhang_layer = class.class("tile_overhang_layer", IDrawLayer)

function tile_overhang_layer:init(width, height)
   self.width = width
   self.height = height
   self.coords = nil
   self.overhang_batch = tile_batch:new(self.width, self.height)
   self.width = width
   self.height = height
   self.top_shadows = {}
   self.bottom_shadows = {}
   self.tile_width = nil
   self.tile_height = nil
end

function tile_overhang_layer:on_theme_switched(coords)
   local tile_overhang_atlas = atlases.get().tile_overhang

   local tw, th = coords:get_size()

   self.coords = coords
   self.tile_width = tw
   self.tile_height = th
   self.overhang_batch:on_theme_switched(tile_overhang_atlas, self.coords)
end

function tile_overhang_layer:relayout()
end

function tile_overhang_layer:reset()
   self.top_shadows = {}
   self.bottom_shadows = {}
   self.overhang_batch:set_tiles({})
end

function tile_overhang_layer:update(dt, screen_updated)
   if not screen_updated then return end

   local map = Map.current()
   assert(map ~= nil)

   for _, p in ipairs(map._tiles_dirty) do
      local x = (p - 1) % map:width()
      local y = math.floor((p - 1) / map:width())
      local m = map:memory(x, y, "base.map_tile")

      if m then
         local t = m[1]
         local id = t._id
         if t.wall then
            local one_tile_down = map:tile(x, y+1)
            if one_tile_down ~= nil and not one_tile_down.wall then
               id = t.wall
               if t.wall_kind == 2 then
                  self.bottom_shadows[x+y*self.overhang_batch.width] = true
               else
                  self.bottom_shadows[x+y*self.overhang_batch.width] = nil
               end
            else
               self.bottom_shadows[x+y*self.overhang_batch.width] = nil
            end
         else
            self.bottom_shadows[x+y*self.overhang_batch.width] = nil
         end

         if t.wall_kind ~= nil then
            local one_tile_up = map:tile(x, y-1)
            if map:is_memorized(x, y-1) and one_tile_up ~= nil and one_tile_up.wall_kind == nil then
               self.overhang_batch:update_tile(x, y, id)
               self.top_shadows[x+y*self.overhang_batch.width] = true
            else
               self.overhang_batch:update_tile(x, y, nil)
               self.top_shadows[x+y*self.overhang_batch.width] = nil
            end
         else
            self.overhang_batch:update_tile(x, y, nil)
            self.top_shadows[x+y*self.overhang_batch.width] = nil
         end
      else
         self.overhang_batch:update_tile(x, y, nil)
         self.top_shadows[x+y*self.overhang_batch.width] = nil
      end
   end

   -- HACK: Also used by tile_layer, but not cleared there so it can
   -- be used here too...
   map._tiles_dirty = {}

   self.overhang_batch.shadow = Map.calc_shadow(save.base.date.hour, map)
   self.overhang_batch.updated = true
end

function tile_overhang_layer:draw_shadows(draw_x, draw_y, offx, offy)
   -- HACK
   if class.is_an(iso_coords, self.coords) then
      return
   end

   local sx, sy = Draw.get_coords():get_start_offset(draw_x, draw_y)

   Draw.set_blend_mode("subtract")
   Draw.set_color(255, 255, 255, 20)

   -- Top shadows above wall tiles
   for ind, _ in pairs(self.top_shadows) do
      local x = ind % self.overhang_batch.width
      local y = math.floor(ind / self.overhang_batch.width)
      Draw.filled_rect(x * self.tile_width - draw_x - offx + sx,
                       y * self.tile_height - draw_y - offy + sy - 20,
                       self.tile_width,
                       math.floor(self.tile_height / 6))
   end

   -- Bottom shadows below wall tiles
   for ind, _ in pairs(self.bottom_shadows) do
      local x = ind % self.overhang_batch.width
      local y = math.floor(ind / self.overhang_batch.width)

      Draw.set_color(255, 255, 255, 16)
      Draw.filled_rect(x * self.tile_width - draw_x - offx + sx,
                       (y+1) * self.tile_height - draw_y - offy + sy,
                       self.tile_width,
                       math.floor(self.tile_height / 2))

      Draw.set_color(255, 255, 255, 12)
      Draw.filled_rect(x * self.tile_width - draw_x - offx + sx,
                       (y+1) * self.tile_height - draw_y - offy + sy + 24,
                       self.tile_width,
                       math.floor(self.tile_height / 4))
   end

   Draw.set_blend_mode("alpha")
   Draw.set_color(255, 255, 255)
end

function tile_overhang_layer:draw(draw_x, draw_y, offx, offy)
   self.overhang_batch:draw(draw_x + offx, draw_y + offy + 12)

   self:draw_shadows(draw_x, draw_y, offx, offy)
end

return tile_overhang_layer
