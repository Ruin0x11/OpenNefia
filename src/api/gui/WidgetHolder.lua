local IUiWidget = require("api.gui.IUiWidget")

local WidgetHolder = class.class("WidgetHolder")

function WidgetHolder:init(widget, tag, z_order, position)
   class.assert_is_an(IUiWidget, widget)
   self._tag = tag
   self._z_order = z_order or 0
   self._position = position
   self._widget = widget
   self._enabled = true
end

function WidgetHolder:z_order()
   return self._z_order
end

function WidgetHolder:set_z_order(z_order)
   self.updated = true
   self._z_order = z_order or 0
end

function WidgetHolder:enabled()
   return self._enabled
end

function WidgetHolder:set_enabled(enabled)
   self.updated = true
   if enabled == nil then
      enabled = true
   end
   self._enabled = enabled
end

function WidgetHolder:position()
   return self._position
end

function WidgetHolder:set_position(position)
   self.updated = true
   self._position = position
end

function WidgetHolder:remove()
   self.updated = true
   self._remove = true
end

function WidgetHolder:widget()
   return self._widget
end

return WidgetHolder
