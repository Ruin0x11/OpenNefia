local IUiElement = require("api.gui.IUiElement")
local IMouseElementProvider = require("api.gui.IMouseElementProvider")

local IUiMouseElement = class.interface("IUiMouseElement", {
                          get_parent = "function",
                          get_minimum_width = "function",
                          get_minimum_height = "function",
                        },
                        {IUiElement, IMouseElementProvider})

function IUiMouseElement:get_parent()
   return self._parent
end

function IUiMouseElement:get_minimum_width()
   return 1
end

function IUiMouseElement:get_minimum_height()
   return 1
end

function IUiMouseElement:get_mouse_elements(recursive)
   return {}
end

return IUiMouseElement
