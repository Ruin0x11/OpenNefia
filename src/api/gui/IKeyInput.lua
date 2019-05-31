local IFocusable = require("api.gui.IFocusable")

return interface("IKeyInput",
                 {
                    receive_key = "function",
                    forward_to = "function",
                    run_action = "function",
                    run_actions = "function"
                 },
                 IFocusable)
