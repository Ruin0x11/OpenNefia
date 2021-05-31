local Draw = require("api.Draw")
local Color = require("mod.extlibs.api.Color")

local IUiMouseButton = require("mod.mouse_ui.api.gui.IUiMouseButton")
local UiShadowedText = require("api.gui.UiShadowedText")
local UiTheme = require("api.gui.UiTheme")
local UiMouseStyle = require("mod.mouse_ui.api.UiMouseStyle")

local UiMouseButton = class.class("UiMouseButton", IUiMouseButton)

function UiMouseButton:init(opts)
   self.text = UiShadowedText:new(opts.text)
   self.pressed = false
   self.enabled = true
   self.callback = opts.callback
end

function UiMouseButton:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = math.max(width, self:get_minimum_width())
   self.height = math.max(height, self:get_minimum_height())
   self.t = UiTheme.load()

   self.color = {192, 192, 192}
   self.color_dark = {Color:new_rgb(self.color):lighten_by(0.5):to_rgb()}
   self.color_light = {Color:new_rgb(self.color):lighten_by(1.5):to_rgb()}
end

function UiMouseButton:get_minimum_width()
   return self.text:text_width() + 6
end

function UiMouseButton:get_minimum_height()
   return self.text:text_height() + 6
end

function UiMouseButton:is_mouse_region_enabled()
   return self.enabled
end

function UiMouseButton:on_mouse_pressed(x, y, button)
   if button == 1 then
      self.pressed = true
      return true
   end
   return false
end

function UiMouseButton:on_mouse_released(x, y, button)
   local run = button == 1 and self:is_mouse_intersecting(x, y)
   self.pressed = false

   if run and self.callback then
      self.callback(x, y, button)
      return true
   end
   return false
end

function UiMouseButton:is_pressed()
   return self.pressed
end

function UiMouseButton:is_enabled()
   return self.enabled
end

function UiMouseButton:set_pressed(pressed)
   self.pressed = pressed
end

function UiMouseButton:set_enabled(enabled)
   self.enabled = enabled
end

function UiMouseButton:set_text(text)
   self.text:set_data(text)
end

function UiMouseButton:set_callback(callback)
   self.callback = callback
end

function UiMouseButton:draw()
   UiMouseStyle.draw_panel(self.x, self.y, self.width, self.height, 2, self.pressed, self.color, self.color_dark, self.color_light)

   local w = self.text:text_width()
   local h = self.text:text_height()
   local x = self.x + (self.width / 2) - (w / 2)
   local y = self.y + (self.height / 2) - (h / 2)
   if self.pressed then
      x = x + 2
      y = y + 2
   end
   self.text:relayout(x, y)

   self.text:draw()
end

function UiMouseButton:update(dt)
end

return UiMouseButton
