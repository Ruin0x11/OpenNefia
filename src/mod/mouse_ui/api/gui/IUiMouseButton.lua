local IUiMouseElement = require("mod.mouse_ui.api.gui.IUiMouseElement")
local IMouseElement = require("api.gui.IMouseElement")

local IUiMouseButton = class.interface("IUiMouseButton", {
                          is_pressed = "function",
                          is_enabled = "function",
                          set_pressed = "function",
                          set_enabled = "function",
                       },
                       {IUiMouseElement, IMouseElement})

function IUiMouseButton:get_mouse_elements(recursive)
   return {}
end

return IUiMouseButton
