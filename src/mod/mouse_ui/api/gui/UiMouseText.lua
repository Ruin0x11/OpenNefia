local Color = require("mod.extlibs.api.Color")

local IUiMouseElement = require("mod.mouse_ui.api.gui.IUiMouseElement")
local UiShadowedText = require("api.gui.UiShadowedText")
local UiTheme = require("api.gui.UiTheme")

local UiMouseText = class.class("UiMouseText", IUiMouseElement)

function UiMouseText:init(opts)
   self.text = UiShadowedText:new(opts.text or "", opts.font_size or 14)
end

function UiMouseText:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = math.max(width, self:get_minimum_width())
   self.height = math.max(height, self:get_minimum_height())
   self.t = UiTheme.load()

   self.color = {192, 192, 192}
   self.color_dark = {Color:new_rgb(self.color):lighten_by(0.5):to_rgb()}
   self.color_light = {Color:new_rgb(self.color):lighten_by(1.5):to_rgb()}
end

function UiMouseText:get_minimum_width()
   return self.text:text_width() + 6
end

function UiMouseText:get_minimum_height()
   return self.text:text_height() + 6
end

function UiMouseText:set_text(text)
   self.text:set_data(text)
end

function UiMouseText:draw()
   local w = self.text:text_width()
   local h = self.text:text_height()
   local x = self.x + (self.width / 2) - (w / 2)
   local y = self.y + (self.height / 2) - (h / 2)
   self.text:relayout(x, y)
   self.text:draw()
end

function UiMouseText:update(dt)
end

return UiMouseText
