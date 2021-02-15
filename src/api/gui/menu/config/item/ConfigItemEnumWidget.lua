local UiTheme = require("api.gui.UiTheme")
local IConfigItemWidget = require("api.gui.menu.config.item.IConfigItemWidget")
local Draw = require("api.Draw")
local I18N = require("api.I18N")

local ConfigItemEnumWidget = class.class("ConfigItemEnumWidget", IConfigItemWidget)

function ConfigItemEnumWidget:init(item)
   IConfigItemWidget.init(self, item)

   self.item = item
   self.text = ""
   self.choices = self.item.choices
   if type(self.choices) == "function" then
      self.choices = self.choices()
      assert(type(self.choices) == "table")
   end
   self:set_value(assert(self.choices[1]))
end

function ConfigItemEnumWidget:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
end

function ConfigItemEnumWidget:get_value()
   return self.value
end

function ConfigItemEnumWidget:can_change()
   local change_left, change_right = true, true
   if self.choices[1] == self.value then
      change_left = false
   end
   if self.choices[#self.choices] == self.value then
      change_right = false
   end
   return change_left, change_right
end

function ConfigItemEnumWidget:set_value(value)
   self.value = value
   if self.item.formatter then
      self.text = self.item.formatter(self.item._id, self.value)
   elseif self.item._id then
      self.text = I18N.get_optional("config.option." .. self.item._id .. ".variants." .. self.value) or tostring(self.value)
   else
      self.text = tostring(self.value)
   end
end

function ConfigItemEnumWidget:can_choose()
   return false
end

function ConfigItemEnumWidget:on_choose()
end

function ConfigItemEnumWidget:on_change(delta)
   local cur_pos = table.index_of(self.choices, self.value)
   local new_pos = math.clamp(cur_pos + delta, 1, #self.choices)
   self:set_value(self.choices[new_pos])
end

function ConfigItemEnumWidget:draw()
   local color = self.t.base.text_color
   if not self.enabled then
      color = self.t.base.text_color_disabled
   end

   Draw.set_color(color)
   Draw.text(self.text, self.x, self.y)
end

function ConfigItemEnumWidget:update()
end

return ConfigItemEnumWidget
