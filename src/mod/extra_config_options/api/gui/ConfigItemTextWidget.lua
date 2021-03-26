local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")
local IConfigItemWidget = require("api.gui.menu.config.item.IConfigItemWidget")
local TextEditorPrompt = require("mod.ui_console.api.gui.TextEditorPrompt")

local ConfigItemTextWidget = class.class("ConfigItemTextWidget", IConfigItemWidget)

function ConfigItemTextWidget:init(item)
   IConfigItemWidget.init(self, item)

   self.item = item
   self.value = ""
   self.truncated_value = ""
end

function ConfigItemTextWidget:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
end

function ConfigItemTextWidget:get_value()
   return self.value
end

function ConfigItemTextWidget:set_value(value)
   self.value = value
   local first_line_pos = self.value:find("\n") or 10
   self.truncated_value = self.value:sub(0, first_line_pos-1)
   if #self.value > 7 then
      self.truncated_value = self.truncated_value:sub(0, 7) .. "..."
   end
   local _, line_count = self.value:gsub("\n", "\n")
   self.truncated_value = ("%s (%d)"):format(self.truncated_value, line_count + 1)
end

function ConfigItemTextWidget:can_change()
   return false
end

function ConfigItemTextWidget:on_change(delta)
end

function ConfigItemTextWidget:can_choose()
   return true
end

function ConfigItemTextWidget:on_choose()
   local new_value, canceled = TextEditorPrompt:new(self:get_value()):query()
   if new_value and not canceled then
      self:set_value(new_value)
   end
end

function ConfigItemTextWidget:draw()
   Draw.set_color(self.t.base.text_color)
   Draw.set_font(14)
   Draw.text(self.truncated_value, self.x, self.y)
end

function ConfigItemTextWidget:update()
end

return ConfigItemTextWidget
