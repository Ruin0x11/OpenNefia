local Draw = require("api.Draw")
local Log = require("api.Log")
local PriorityMap = require("api.PriorityMap")
local IDrawLayer = require("api.gui.IDrawLayer")

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

   for tag, entry in draw_layer_spec:iter() do
      local instance
      if class.is_an(IDrawLayer, entry.instance) then
         instance = entry.instance
      else
         -- WARNING: This needs to be sanitized by moving all the layers
         -- to the public API, to prevent usage of the global require.
         local ok, layer = pcall(require, entry.require_path)
         if not ok then
            error("Could not load draw layer " .. tostring(entry.require_path) .. ":\n\t" .. layer)
         end

         instance = layer:new(map_width, map_height)
      end

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

function field_renderer:update_draw_pos(sx, sy)
   local draw_x, draw_y = self.coords:get_draw_pos(sx,
                                                   sy,
                                                   self.map_width,
                                                   self.map_height,
                                                   self.width,
                                                   self.height)

   self:set_draw_pos(draw_x, draw_y)
end

function field_renderer:set_draw_pos(draw_x, draw_y)
   self.draw_x = draw_x
   self.draw_y = draw_y
   self.screen_updated = true
end

function field_renderer:draw_pos()
   return self.draw_x, self.draw_y
end

function field_renderer:force_screen_update()
   self.screen_updated = true
end

function field_renderer:draw(x, y, width, height)
   x = x or self.draw_x
   y = y or self.draw_y
   width = width or self.width
   height = height or self.height

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
   local going = false
   for _, l, tag in self.layers:iter() do
      if self.enabled[tag] ~= false then
         local result = l:update(map, dt, self.screen_updated)
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
