local Draw = require("api.Draw")
local Log = require("api.Log")
local PriorityMap = require("api.PriorityMap")

local sound_manager = require("internal.global.global_sound_manager")

local field_renderer = class.class("field_renderer")

function field_renderer:init(map_width, map_height, draw_layer_spec)
   local coords = Draw.get_coords()

   self.map_width = map_width
   self.map_height = map_height
   self.coords = coords
   self.draw_x = 0
   self.draw_y = 0

   self.screen_updated = true

   self.layers = PriorityMap:new()
   self.enabled = {}

   self.scroll = nil
   self.scroll_frames = 0
   self.scroll_max_frames = 0
   self.scroll_x = 0
   self.scroll_y = 0

   for tag, entry in draw_layer_spec:iter() do
      -- WARNING: This needs to be sanitized by moving all the layers
      -- to the public API, to prevent usage of the global require.
      local ok, layer = pcall(require, entry.require_path)
      if not ok then
         error("Could not load draw layer " .. tostring(entry.require_path) .. ":\n\t" .. layer)
      end
      local IDrawLayer = require("api.gui.IDrawLayer")

      local instance = layer:new(map_width, map_height)
      class.assert_is_an(IDrawLayer, instance)

      -- TODO
      instance:on_theme_switched(coords)
      instance:reset()
      instance:relayout(self.x, self.y, self.width, self.height)

      local z_order = entry.z_order
      if z_order == nil then
         z_order = instance:default_z_order()
      end
      assert(type(z_order) == "number")

      self.layers:set(tag, instance, z_order)
      self.enabled[tag] = entry.enabled
   end
end

function field_renderer:on_theme_switched()
   local coords = Draw.get_coords()
   for _, layer in self.layers:iter() do
      layer:on_theme_switched(coords)
      layer:relayout(self.x, self.y, self.width, self.height)
   end
end

function field_renderer:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   for _, layer in self.layers:iter() do
      layer:relayout(self.x, self.y, self.width, self.height)
   end
end

function field_renderer:get_layer(tag)
   assert(type(tag) == "string")
   return self.layers:get(tag)
end

function field_renderer:set_layer_enabled(tag, enabled)
   assert(type(tag) == "string")
   if not self.layers:get(tag) then
      error(("Layer '%s' isn't registered"):format(tag))
   end
   self.enabled[tag] = not not enabled
end

function field_renderer:set_map_size(map_width, map_height, layers)
   self:init(map_width, map_height, layers)
end

function field_renderer:set_scroll(dx, dy, scroll_frames)
   self.scroll = { dx = dx, dy = dy }
   self.scroll_max_frames = scroll_frames
   self.scroll_frames = self.scroll_max_frames
end

function field_renderer:update_draw_pos(sx, sy, scroll_frames)
   local draw_x, draw_y = self.coords:get_draw_pos(sx,
                                                   sy,
                                                   self.map_width,
                                                   self.map_height,
                                                   self.width,
                                                   self.height - 72 - 16)

   if scroll_frames then
      self:set_scroll(self.draw_x - draw_x, self.draw_y - draw_y, scroll_frames)
   else
      self.scroll = nil
      self.scroll_frames = 0
   end

   self:set_draw_pos(draw_x, draw_y)

   sound_manager:set_listener_pos(sx, sy)
end

function field_renderer:set_draw_pos(draw_x, draw_y)
   self.draw_x = draw_x
   self.draw_y = draw_y
   self.screen_updated = true
end

function field_renderer:draw_pos()
   return self.draw_x, self.draw_y, self.scroll_x, self.scroll_y
end

function field_renderer:draw(x, y, width, height)
   x = x or self.draw_x
   y = y or self.draw_y
   width = width or self.width
   height = height or (self.height - 72 - 16)

   for _, l, tag in self.layers:iter() do
      if self.enabled[tag] ~= false then
         local ok, result = xpcall(function() l:draw(x, y, width, height) end, debug.traceback)
         if not ok then
            Log.error("%s", result)
         end
      end
   end
end

function field_renderer:update(map, dt)
   -- BUG: this really doesn't look like the original Elona's
   -- scrolling. The issue is here it is based on dt. In vanilla
   -- scrolling would always scroll by a fixed amount of pixels
   -- between 40ms pauses, regardless of framerate. This meant the
   -- framerate the game ran at affected the speed of scrolling, but
   -- the effect ends up being different. There should be a
   -- compatability option for vanilla.
   if self.scroll then
      self.scroll_frames = self.scroll_frames - Draw.msecs_to_frames(dt*1000)
      if self.scroll_frames <= 0 then
         self.scroll = nil
         self.scroll_x = 0
         self.scroll_y = 0
      else
         local p = 1 - (self.scroll_frames/self.scroll_max_frames)
         self.scroll_x = (self.scroll.dx - (p * self.scroll.dx))
         self.scroll_y = (self.scroll.dy - (p * self.scroll.dy))
      end
   end

   local going = false
   for _, l, tag in self.layers:iter() do
      if self.enabled[tag] ~= false then
         local result = l:update(map, dt, self.screen_updated, self.scroll_frames)
         if result then -- not nil or false
            going = true
         end
      end
   end

   if not going then
      self.screen_updated = false
   end

   return going
end

return field_renderer
