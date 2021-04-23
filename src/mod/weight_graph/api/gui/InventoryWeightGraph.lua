local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local TopicWindow = require("api.gui.TopicWindow")
local UiTheme = require("api.gui.UiTheme")
local Color = require("mod.extlibs.api.Color")

local InventoryWeightGraph = class.class("InventoryWeightGraph", IUiElement)

function InventoryWeightGraph:init(position)
   self.topic_win = TopicWindow:new(1, 1)
   self.weight_max = 0
   self.weight_current = 0
   self.weight_delta = 0
   self.add = "add"
   self.position = position or "left"
   self.markers = {}
end

function InventoryWeightGraph:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width -- 24
   self.height = height -- 408

   self.t = UiTheme.load(self)

   self.topic_win:relayout(self.x, self.y, self.width, self.height)
end

function InventoryWeightGraph:set_weight(max, current, delta, add)
   self.weight_max = max
   self.weight_current = current
   self.weight_delta = delta
   self.add = add
end

function InventoryWeightGraph:set_markers(markers)
   self.markers = markers
   -- self.markers = {
   --    { weight = self.weight_max, text = "Max" },
   --    { weight = self.weight_max / 2, text = "Heavy" },
   --    { weight = (self.weight_max / 2) / 4 * 3, text = "Moderate" },
   --    { weight = (self.weight_max / 2) / 2, text = "Light" },
   -- }
end

function InventoryWeightGraph:draw()
   self.topic_win:draw()

   local pad = 4
   local h = self.height - (pad * 2)

   Draw.set_scissor(self.x + pad, self.y + pad, self.width, self.height)

   local weight_max = self.weight_max
   if self.add == "add" then
      weight_max = math.max(weight_max, self.weight_current + self.weight_delta)
   else
      weight_max = math.max(weight_max, self.weight_current)
   end

   local bar_current = h * (self.weight_current / weight_max)
   local bar_delta = math.abs(h * (self.weight_delta / weight_max))

   local bar_y = self.y + self.height - bar_current - pad
   local bar_delta_y
   local bar_delta_color

   if self.add == "add" then
      bar_delta_y = bar_y - bar_delta
      bar_delta_color = self.t.weight_graph.weight_delta_add
   else
      bar_delta_y = bar_y
      bar_delta_color = self.t.weight_graph.weight_delta_subtract
   end

   Draw.set_color(self.t.weight_graph.weight_current)
   Draw.filled_rect(self.x + pad, bar_y, self.width - pad * 2, bar_current)

   Draw.set_color(bar_delta_color)
   Draw.filled_rect(self.x + pad, bar_delta_y, self.width - pad * 2, bar_delta)

   Draw.set_scissor()
   Draw.set_font(14)
   local th = Draw.text_height()

   local text_color = self.t.base.text_color_light
   local text_color_dim = {Color:new_rgb(self.t.base.text_color_light):lighten_to(0.75):to_rgb()}

   for _, marker in ipairs(self.markers) do
      local marker_y = self.y - pad + self.height - h * (marker.weight / weight_max)
      local color = text_color

      if self.add == "add" then
         if marker.weight > self.weight_current and marker.weight <= self.weight_current + self.weight_delta then
            color = self.t.weight_graph.weight_delta_add
         elseif marker.weight > self.weight_current + self.weight_delta then
            color = text_color_dim
         end
      else
         if marker.weight > self.weight_current - self.weight_delta and marker.weight <= self.weight_current then
            color = self.t.weight_graph.weight_delta_subtract
         elseif marker.weight > self.weight_current then
            color = text_color_dim
         end
      end

      Draw.set_color(self.t.weight_graph.weight_marker)
      Draw.line(self.x + pad, marker_y, self.x + self.width - pad, marker_y)

      local text_x
      if self.position == "left" then
         text_x = self.x + self.width - 32 - Draw.text_width(marker.text)
      else
         text_x = self.x + self.width + 16
      end

      Draw.text_shadowed(marker.text, text_x, marker_y - th / 2, color)
   end
end

function InventoryWeightGraph:update(dt)
end

return InventoryWeightGraph
