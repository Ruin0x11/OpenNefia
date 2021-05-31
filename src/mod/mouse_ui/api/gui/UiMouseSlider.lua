local Color = require("mod.extlibs.api.Color")
local Input = require("api.Input")
local Log = require("api.Log")

local IUiMouseButton = require("mod.mouse_ui.api.gui.IUiMouseButton")
local UiTheme = require("api.gui.UiTheme")
local UiMouseStyle = require("mod.mouse_ui.api.UiMouseStyle")

local UiMouseSlider = class.class("UiMouseSlider", IUiMouseButton)

function UiMouseSlider:init(opts)
   self.pressed = false
   self.enabled = true

   self.min_width = opts.min_width or 20
   self.min_height = opts.min_height or 20

   self.on_changed = opts.on_changed or nil
   self.min_value = opts.min_value or 0
   self.max_value = math.max(opts.max_value or (self.min_value + 1), 100)
   self.value = 0
   self.step = opts.step or 1

   self:set_value(opts.value or self.min_value)

   self.dragging = false
   self.drag_value = self.value
   self.drag_x = 0
   self.drag_y = 0
end

function UiMouseSlider:_update_slider()
   local scale = self.value / (self.max_value - self.min_value)

   self.slider_width = math.floor(self.width * 0.1)
   self.slider_height = self.height
   self.slider_x = self.x + (self.width - self.slider_width) * scale
   self.slider_y = self.y + self.height / 2 - self.slider_height /2
end

function UiMouseSlider:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = math.max(width, self:get_minimum_width())
   self.height = math.max(height, self:get_minimum_height())
   self.t = UiTheme.load()

   self.color = {192, 192, 192}
   self.color_bar = {Color:new_rgb(self.color):lighten_by(0.75):to_rgb()}
   self.color_dark = {Color:new_rgb(self.color):lighten_by(0.5):to_rgb()}
   self.color_light = {Color:new_rgb(self.color):lighten_by(1.5):to_rgb()}

   self:_update_slider()
end

function UiMouseSlider:get_minimum_width()
   return self.min_width
end

function UiMouseSlider:get_minimum_height()
   return self.min_height
end

function UiMouseSlider:is_mouse_region_enabled()
   return self.enabled
end

function UiMouseSlider:on_mouse_pressed(x, y, button)
   if button == 1 then
      self.pressed = true
      if x >= self.slider_x
         and y >= self.slider_y
         and x < self.slider_x + self.slider_width
         and y < self.slider_y + self.slider_height
      then
         self.dragging = true
         self.drag_value = self.value
         self.drag_x = x
         self.drag_y = y
      end
      return true
   end
   return false
end

function UiMouseSlider:on_mouse_released(x, y, button)
   self.pressed = false
   self.dragging = false

   return false
end

function UiMouseSlider:is_pressed()
   return self.pressed
end

function UiMouseSlider:is_enabled()
   return self.enabled
end

function UiMouseSlider:set_pressed(pressed)
   self.pressed = pressed
   if not pressed then
      self.dragging = false
   end
end

function UiMouseSlider:set_enabled(enabled)
   self.enabled = enabled
end

function UiMouseSlider:set_text(text)
   self.text:set_data(text)
end

function UiMouseSlider:set_on_changed(on_changed)
   self.on_changed = on_changed
end

function UiMouseSlider:get_value()
   return self.value
end

local function round_increment(v, increment, offset)
   return math.floor((v-offset)/increment) * increment + offset
end

function UiMouseSlider:set_value(value)
   assert(type(value) == "number")
   self.value = math.clamp(round_increment(value, self.step, self.min_value), self.min_value, self.max_value)
   if self.on_changed then
      self.on_changed(self.value)
   end
end

function UiMouseSlider:draw()
   UiMouseStyle.draw_panel(self.x, self.slider_y, self.width, self.slider_height, 2, true, self.color_bar, self.color_dark, self.color_light)

   UiMouseStyle.draw_panel(self.slider_x, self.slider_y, self.slider_width, self.slider_height, 2, self.dragging, self.color, self.color_dark, self.color_light)

   local offset_x = 0
   local offset_y = 0
   if self.dragging then
      offset_x = 2
      offset_y = 0
   end
   UiMouseStyle.draw_vertical_line(self.slider_x + self.slider_width / 2 + offset_x, self.slider_y + 2 + offset_y, self.slider_y + self.slider_height - 4 + offset_y, self.color_dark, self.color_light)
end

function UiMouseSlider:update(dt)
   if self.dragging then
      local mouse_x, mouse_y = Input.mouse_pos()
      local dx = mouse_x - self.drag_x
      local dy = mouse_y - self.drag_y
      self.drag_x = mouse_x
      self.drag_y = mouse_y

      local delta = math.map(math.abs(dx), 0, self.width, 0, self.max_value - self.min_value, true)
      delta = delta * math.sign(dx)
      self.drag_value = self.drag_value + delta
      self:set_value(self.drag_value)
      self:_update_slider()
   end
end

return UiMouseSlider
