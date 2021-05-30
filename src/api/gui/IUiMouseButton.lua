local IMouseElement = require("api.gui.IMouseElement")

return class.interface("IUiMouseButton", {
                          is_pressed = "function",
                          is_enabled = "function",
                          set_pressed = "function",
                          set_enabled = "function",
                                         }, IMouseElement)
