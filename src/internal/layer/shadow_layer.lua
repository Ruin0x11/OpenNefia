local Chara = require("api.Chara")
local Draw = require("api.Draw")
local IDrawLayer = require("api.gui.IDrawLayer")
local Map = require("api.Map")
local Pos = require("api.Pos")
local save = require("internal.global.save")
local shadow_batch = require("internal.draw.shadow_batch")

local shadow_layer = class.class("shadow_layer", IDrawLayer)

function shadow_layer:init(width, height, coords)
   local coords = Draw.get_coords()

   self.shadow_batch = shadow_batch:new(width, height, coords)
   self.reupdate = true
end

function shadow_layer:relayout()
end

function shadow_layer:reset()
   self.batch_inds = {}
end

function shadow_layer:update(dt, screen_updated, scroll_frames)
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

   local shadow = save.base.shadow
   local has_light_source = save.base.has_light_source
   local is_dungeon = map:has_type("dungeon")
   if has_light_source and is_dungeon then
      shadow = shadow - 50
   end

   local player = Chara.player()
   if player then
      for _, x, y, tile in map:iter_tiles() do
         if tile.light then
            local power = Pos.dist(player.x, player.y, x, y)
            power = math.clamp(power, 0, 6) * tile.light.power
            shadow = shadow - power
            -- TODO draw light
         end
      end
   end

   shadow = math.max(shadow, 25)

   self.shadow_batch.shadow_strength = shadow

   self.reupdate = false

   return false
end

function shadow_layer:draw(draw_x, draw_y, offx, offy)
   self.shadow_batch:draw(draw_x, draw_y, 0, 0)
end

return shadow_layer
