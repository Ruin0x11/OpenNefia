local UiTheme = require("api.gui.UiTheme")
local IConfigItemWidget = require("api.gui.menu.config.item.IConfigItemWidget")
local Draw = require("api.Draw")

local ConfigItemIntegerWidget = class.class("ConfigItemIntegerWidget", IConfigItemWidget)

function ConfigItemIntegerWidget:init(item)
   IConfigItemWidget.init(self, item)

   self.item = item
   self.value = 0
   self.min_value = item.min_value or nil
   self.max_value = item.max_value or nil
end

function ConfigItemIntegerWidget:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
end

function ConfigItemIntegerWidget:get_value()
   return self.value
end

function ConfigItemIntegerWidget:can_change()
   local change_left, change_right = true, true
   if self.min_value and self.value <= self.min_value then
      change_left = false
   end
   if self.max_value and self.value >= self.max_value then
      change_right = false
   end
   return change_left, change_right
end

function ConfigItemIntegerWidget:set_value(value)
   self.value = math.clamp(value, self.min_value or value, self.max_value or value)
end

function ConfigItemIntegerWidget:can_choose()
   return false
end

function ConfigItemIntegerWidget:on_choose()
end

function ConfigItemIntegerWidget:on_change(delta)
   self:set_value(self.value + delta)
end

function ConfigItemIntegerWidget:draw()
   local color = self.t.base.text_color
   if not self.enabled then
      color = self.t.base.text_color_disabled
   end

   Draw.set_color(color)
   Draw.text(tostring(self.value), self.x, self.y)
end

function ConfigItemIntegerWidget:update()
end

return ConfigItemIntegerWidget
