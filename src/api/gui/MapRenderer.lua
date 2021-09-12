local IUiElement = require("api.gui.IUiElement")
local InstancedMap = require("api.InstancedMap")
local DrawLayerSpec = require("api.draw.DrawLayerSpec")
local field_renderer = require("internal.field_renderer")
local Draw = require("api.Draw")

local MapRenderer = class.class("MapRenderer", IUiElement)

function MapRenderer:init(map, draw_layer_spec)
   if draw_layer_spec == nil then
      local Gui = require("api.Gui")
      draw_layer_spec = Gui.current_draw_layer_spec()
   end

   class.assert_is_an(DrawLayerSpec, draw_layer_spec)
   self.draw_layer_spec = draw_layer_spec
   self.renderer = field_renderer:new(1, 1, self.draw_layer_spec)
   self.map = nil

   self:set_map(map)
end

function MapRenderer:set_map(map)
   if map ~= nil then
      class.assert_is_an(InstancedMap, map)
      self.map = map
      self.renderer:set_map_size(self.map:width(), self.map:height(), self.draw_layer_spec)
      self.renderer:relayout(self.x, self.y, self.width, self.height)
      self:on_theme_switched()
   else
      self.map = nil
   end
end

function MapRenderer:on_theme_switched()
   if self.map then
      self.map:redraw_all_tiles()
   end

   self.renderer:on_theme_switched()
end

function MapRenderer:iter_draw_layers()
   return self.draw_layer_spec:iter()
end

function MapRenderer:get_draw_layer(tag)
   return self.renderer:get_layer(tag)
end

function MapRenderer:set_draw_layer_enabled(tag, enabled)
   self.draw_layer_spec:set_draw_layer_enabled(tag, enabled)
   return self.renderer:set_layer_enabled(tag, enabled)
end

function MapRenderer:set_draw_pos(draw_x, draw_y)
   self.renderer:set_draw_pos(draw_x, draw_y)
end

function MapRenderer:update_draw_pos(sx, sy)
   self.renderer:update_draw_pos(sx, sy)
end

function MapRenderer:get_draw_pos()
   return self.renderer:draw_pos()
end

function MapRenderer:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = math.floor(width)
   self.height = math.floor(height)

   self.canvas = Draw.create_canvas(self.width, self.height)
   self.renderer:relayout(x, y, width, height)
end

function MapRenderer:force_screen_update()
   self.renderer:force_screen_update()
end

function MapRenderer:relayout_inner(x, y, width, height)
end

function MapRenderer:draw()
   if self.map then
      Draw.with_canvas(self.canvas, function()
                          Draw.clear(0, 0, 0)
                          self.renderer:draw(nil, nil, self.width, self.height)
                       end)
      Draw.set_color(255, 255, 255)
      Draw.image(self.canvas, self.x, self.y)
   end
end

function MapRenderer:update(dt)
   if self.map then
      self.renderer:update(self.map, dt)
   end
end

return MapRenderer
