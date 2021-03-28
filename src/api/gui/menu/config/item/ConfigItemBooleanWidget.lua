local UiTheme = require("api.gui.UiTheme")
local IConfigItemWidget = require("api.gui.menu.config.item.IConfigItemWidget")
local Draw = require("api.Draw")
local I18N = require("api.I18N")

local ConfigItemBooleanWidget = class.class("ConfigItemBooleanWidget", IConfigItemWidget)

function ConfigItemBooleanWidget:init(item)
   IConfigItemWidget.init(self, item)

   self.item = item
   self.text = ""
   self:set_value(false)
end

function ConfigItemBooleanWidget:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
end

function ConfigItemBooleanWidget:get_value()
   return self.value
end

function ConfigItemBooleanWidget:can_change()
   if self.value == false then
      return false, true
   elseif self.value == true then
      return true, false
   end
end

function ConfigItemBooleanWidget:set_value(value)
   self.value = value

   local key = self.value and "yes" or "no"
   local _id = self.item._id
   if _id == nil then
      self.text = I18N.get("config.common.yes_no.default." .. key)
   else
      local locale_root = "config.option." .. _id
      self.text = I18N.get_optional(locale_root .. "." .. key)
      if self.text == nil then
         local yes_no = I18N.get_optional(locale_root .. ".yes_no") or "config.common.yes_no.default"
         self.text = I18N.get(yes_no .. "." .. key)
      end
   end
end

function ConfigItemBooleanWidget:can_choose()
   return false
end

function ConfigItemBooleanWidget:on_choose()
end

function ConfigItemBooleanWidget:on_change(delta)
   if delta > 0 then
      self:set_value(true)
   else
      self:set_value(false)
   end
end

function ConfigItemBooleanWidget:draw()
   local color = self.t.base.text_color
   if not self.enabled then
      color = self.t.base.text_color_disabled
   end

   Draw.set_color(color)
   Draw.text(self.text, self.x, self.y)
end

function ConfigItemBooleanWidget:update()
end

return ConfigItemBooleanWidget
