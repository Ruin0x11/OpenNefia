local IMouseElement = require("api.gui.IMouseElement")

return class.interface("IUiMouseButton", {
                          get_minimum_width = "function",
                          get_minimum_height = "function",
                          is_pressed = "function",
                          is_enabled = "function",
                          set_pressed = "function",
                          set_enabled = "function",
                                         }, IMouseElement)
