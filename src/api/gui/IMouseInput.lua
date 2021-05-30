local IInputHandler = require("api.gui.IInputHandler")

return class.interface("IMouseInput",
                 {
                    receive_mouse_movement = "function",
                    receive_mouse_button = "function",
                    run_mouse_action = "function",
                    run_mouse_element_action = "function",
                    run_mouse_movement_action = "function",
                    bind_mouse = "function",
                    bind_mouse_elements = "function",
                    unbind_mouse_elements = "function"
                 },
                 IInputHandler)
