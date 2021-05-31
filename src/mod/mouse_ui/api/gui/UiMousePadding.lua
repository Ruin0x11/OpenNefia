local IUiMousePadding = require("mod.mouse_ui.api.gui.IUiMousePadding")

local UiMousePadding = class.class("UiMousePadding", IUiMousePadding)

function UiMousePadding:init(top, left, right, bottom)
   self.top = top or 0
   self.left = left or 0
   self.right = right or 0
   self.bottom = bottom or 0
end

function UiMousePadding:new_all(value)
   return UiMousePadding:new(value, value, value, value)
end

function UiMousePadding:new_symmetric(vertical, horizontal)
   return UiMousePadding:new(vertical, horizontal, horizontal, vertical)
end

function UiMousePadding:get_padding()
   return self.top, self.left, self.right, self.bottom
end

return UiMousePadding
