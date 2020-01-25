local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local tile_batch = require("internal.draw.tile_batch")
local save = require("internal.global.save")

local tile_overhang_layer = class.class("tile_overhang_layer", IDrawLayer)

function tile_overhang_layer:init(width, height, coords)
   local coords = Draw.get_coords()
   local tile_overhang_atlas = require("internal.global.atlases").get().tile_overhang
   local tw, th = coords:get_size()

   self.overhang_batch = tile_batch:new(width, height, tile_overhang_atlas, coords, tw, th)
   self.top_shadows = {}
   self.bottom_shadows = {}
   self.tile_width = tw
   self.tile_height = th
end

function tile_overhang_layer:relayout()
end

function tile_overhang_layer:reset()
   self.batch_inds = {}
end

local function calc_map_shadow(map, hour)
   if not map.is_outdoor then
      return 0
   end

   local shadow = 0

   if hour >= 24 or (hour >= 0 and hour < 4) then
      shadow = 110
   elseif hour >= 4 and hour < 10 then
      shadow = math.max(10, 70 - (hour - 3) * 10)
   elseif hour >= 10 and hour < 12 then
      shadow = 10
   elseif hour >= 12 and hour < 17 then
      shadow = 1
   elseif hour >= 17 and hour < 21 then
      shadow = (hour - 17) * 20
   elseif hour >= 21 and hour < 24 then
      shadow = 80 + (hour - 21) * 10
   end

   -- TODO weather, noyel

   return shadow
end

function tile_overhang_layer:update(dt, screen_updated)
   if not screen_updated then return end

   local map = Map.current()
   assert(map ~= nil)

   for _, p in ipairs(map._tiles_dirty) do
      local x = p[1]
      local y = p[2]
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
            if one_tile_up ~= nil and one_tile_up.wall_kind == nil then
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

   self.overhang_batch.shadow = calc_map_shadow(map, save.base.date.hour)
   self.overhang_batch.updated = true
end

function tile_overhang_layer:draw_shadows(draw_x, draw_y, offx, offy)
   local sx, sy = Draw.get_coords():get_start_offset(draw_x, draw_y)

   love.graphics.setBlendMode("subtract")
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

   love.graphics.setBlendMode("alpha")
   Draw.set_color(255, 255, 255)
end

function tile_overhang_layer:draw(draw_x, draw_y, offx, offy)
   Draw.set_color(255, 255, 255)
   self.overhang_batch:draw(draw_x + offx, draw_y + offy + 12)

   self:draw_shadows(draw_x, draw_y, offx, offy)
end

return tile_overhang_layer
