local IFocusable = require("api.gui.IFocusable")

return interface("IMouseInput",
                 {
                    receive_mouse_movement = "function",
                    receive_mouse_button = "function",
                 },
                 IFocusable)
