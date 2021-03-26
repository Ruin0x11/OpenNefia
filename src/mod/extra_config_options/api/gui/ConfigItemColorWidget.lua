local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")

local IConfigItemWidget = require("api.gui.menu.config.item.IConfigItemWidget")
local ColorEditorMenu = require("mod.extra_config_options.api.gui.ColorEditorMenu")

local ConfigItemColorWidget = class.class("ConfigItemColorWidget", IConfigItemWidget)

function ConfigItemColorWidget:init(item)
   IConfigItemWidget.init(self, item)

   self.item = item
   self.value = { 255, 255, 255 }
end

function ConfigItemColorWidget:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
end

function ConfigItemColorWidget:get_value()
   return self.value
end

function ConfigItemColorWidget:set_value(value)
   self.value = value
end

function ConfigItemColorWidget:can_change()
   return false
end

function ConfigItemColorWidget:on_change(delta)
end

function ConfigItemColorWidget:can_choose()
   return true
end

function ConfigItemColorWidget:on_choose()
   local new_value, canceled = ColorEditorMenu:new(table.deepcopy(self:get_value())):query()
   if new_value and not canceled then
      self:set_value(new_value)
   end
end

function ConfigItemColorWidget:draw()
   Draw.set_color(self.t.base.text_color)
   Draw.line_rect(self.x-1, self.y-1, 20, 20)
   Draw.set_color(self.value)
   Draw.filled_rect(self.x, self.y, 18, 18)
end

function ConfigItemColorWidget:update()
end

return ConfigItemColorWidget
