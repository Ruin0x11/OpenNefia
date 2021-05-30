local IUiElement = require("api.gui.IUiElement")

local IMouseElement = class.interface("IMouseElement",
                 {
                    get_parent = "function",
                    is_mouse_region_enabled = "function",
                    is_mouse_intersecting = "function",
                    on_mouse_pressed = "function",
                    on_mouse_released = "function",
                 },
                 IUiElement)

function IMouseElement:get_parent()
   return self._parent
end

function IMouseElement:is_mouse_region_enabled(x, y, button, pressed)
   return true
end

function IMouseElement:is_mouse_intersecting(x, y, button, pressed)
   return self.x <= x and self.y <= y and x < (self.x + self.width) and y < (self.y + self.height)
end

function IMouseElement:on_mouse_pressed(x, y, button)
end

function IMouseElement:on_mouse_released(x, y, button)
end

return IMouseElement
