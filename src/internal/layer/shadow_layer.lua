local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
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

   self.reupdate = false

   return false
end

function shadow_layer:draw(draw_x, draw_y)
   self.shadow_batch:draw(draw_x, draw_y)
end

return shadow_layer
