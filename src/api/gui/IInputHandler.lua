local IFocusable = require("api.gui.IFocusable")

return interface("IInputHandler",
                 {
                    forward_to = "function",
                    run_actions = "function",
                    halt_input = "function",
                 },
                 IFocusable)
