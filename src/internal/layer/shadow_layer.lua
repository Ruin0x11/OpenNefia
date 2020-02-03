local config = require("internal.config")
local save = require("internal.global.save")
local shadow_batch = require("internal.draw.shadow_batch")
local Chara = require("api.Chara")
local IDrawLayer = require("api.gui.IDrawLayer")
local Map = require("api.Map")
local Pos = require("api.Pos")
local Rand = require("api.Rand")
local UiTheme = require("api.gui.UiTheme")

local shadow_layer = class.class("shadow_layer", IDrawLayer)

function shadow_layer:init(width, height, coords)
   self.coords = coords
   self.shadow_batch = shadow_batch:new(width, height, coords)
   self.lights = {}
   self.frames = 0
   self.reupdate = true
   self.reupdate_light = false
end

function shadow_layer:relayout()
   self.t = UiTheme.load(self)
end

function shadow_layer:reset()
   self.batch_inds = {}
   self.lights = {}
end

function shadow_layer:rebuild_light(map)
   self.lights = {}

   local shadow = save.base.shadow
   local has_light_source = save.base.has_light_source
   local is_dungeon = map:has_type("dungeon")
   if has_light_source and is_dungeon then
      shadow = shadow - 50
   end

   local player = Chara.player()
   local hour = save.base.date.hour

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

               table.insert(self.lights, {
                  instance = self.t[light.chip]:make_instance(),
                  x = sx,
                  y = sy,
                  y_offset = light.y_offset,
                  color = {255, 255, 255, 255},
                  frame = 1
               })
            end
         end
      end
   end

   shadow = math.max(shadow, 25)

   self.shadow_batch.shadow_strength = shadow
end

function shadow_layer:update_light_flicker()
   for _, light in ipairs(self.lights) do
      local flicker = light.brightness + Rand.rnd(light.flicker + 1)
      light.color[4] = flicker

      local frame_count = #light.chip:regions()
      if frame_count > 1 then
         light.frame = Rand.rnd(frame_count) + 1
      else
         light.frame = 1
      end
   end
end

function shadow_layer:update(dt, screen_updated, scroll_frames)
   self.frames = self.frames + dt * config["base.screen_sync"]
   if self.frames > 1 then
      self.frames = math.fmod(self.frames, 1)
      self.reupdate_light = true
   end

   if self.reupdate then
      local map = Map.current()
      assert(map ~= nil)

      self:rebuild_light(map)
   end

   if self.reupdate or self.reupdate_light then
      self:update_light_flicker()
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
   for _, light in ipairs(self.lights) do
      light.instance:draw_region(light.frame, light.x, light.y)
   end

   self.shadow_batch:draw(draw_x, draw_y, 0, 0)
end

return shadow_layer
