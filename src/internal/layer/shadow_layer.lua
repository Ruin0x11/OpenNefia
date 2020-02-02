local save = require("internal.global.save")
local atlases = require("internal.global.atlases")
local shadow_batch = require("internal.draw.shadow_batch")
local sparse_batch = require("internal.draw.sparse_batch")
local Chara = require("api.Chara")
local IDrawLayer = require("api.gui.IDrawLayer")
local Map = require("api.Map")
local Pos = require("api.Pos")
local Rand = require("api.Rand")

local shadow_layer = class.class("shadow_layer", IDrawLayer)

function shadow_layer:init(width, height, coords)
   local chip_atlas = atlases.get().chip

   self.coords = coords
   self.shadow_batch = shadow_batch:new(width, height, coords)
   self.light_batch = sparse_batch:new(width, height, chip_atlas, coords)
   self.frames = 0
   self.reupdate = true
   self.reupdate_light = false
end

function shadow_layer:relayout()
end

function shadow_layer:reset()
   self.batch_inds = {}
end

function shadow_layer:recalc_light(map)
   local shadow = save.base.shadow
   local has_light_source = save.base.has_light_source
   local is_dungeon = map:has_type("dungeon")
   if has_light_source and is_dungeon then
      shadow = shadow - 50
   end

   local player = Chara.player()
   local hour = save.base.date.hour

   self.light_batch.updated = true
   self.light_batch:clear()

   if player then
      for _, x, y, tile in map:iter_tiles() do
         local light = map:light(x, y)
         if light then
            local show_light = light.always_on or (hour > 17 or hour < 6)
            if show_light then
               local power = Pos.dist(player.x, player.y, x, y)
               power = math.clamp(power, 0, 6) * tile.light.power
               shadow = shadow - power

               local sx, sy = self.coords:tile_to_screen(x + 1, y + 1)
               local flicker = light.brightness + Rand.rnd(light.flicker + 1)
               local color = {255, 255, 255, flicker}
               self.light_batch:add_tile {
                  tile = light.chip,
                  x = sx,
                  y = sy,
                  y_offset = light.y_offset,
                  color = color
               }
            end
         end
      end
   end

   shadow = math.max(shadow, 25)

   self.shadow_batch.shadow_strength = shadow
end

function shadow_layer:update(dt, screen_updated, scroll_frames)
   self.frames = self.frames + dt * 6
   self.light_batch:update(dt)
   if self.frames > 1 then
      self.frames = math.fmod(self.frames, 1)
      self.reupdate_light = true
   end

   if self.reupdate or self.reupdate_light then
      local map = Map.current()
      assert(map ~= nil)

      self:recalc_light(map)
      self.reupdate_light = false
   end

   if not (screen_updated or self.reupdate) then return false end

   -- In vanilla, the shadow map is only updated after the screen
   -- finishes scrolling. The following code simulates this.
   if not self.reupdate and scroll_frames > 0 then
      return true
   end

   self.shadow_batch.updated = true

   local map = Map.current()
   assert(map ~= nil)

   local shadow_map = map:shadow_map()
   if #shadow_map > 0 then
      self.shadow_batch:set_tiles(shadow_map)
   end

   self.reupdate = false

   return false
end

function shadow_layer:draw(draw_x, draw_y, offx, offy)
   self.light_batch:draw(draw_x, draw_y, 0, 0)
   self.shadow_batch:draw(draw_x, draw_y, 0, 0)
end

return shadow_layer
