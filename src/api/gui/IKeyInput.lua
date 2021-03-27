local IInputHandler = require("api.gui.IInputHandler")
assert(type(IInputHandler) == "table")

return class.interface("IKeyInput",
                 {
                    receive_key = "function",
                    run_key_action = "function",
                    run_text_action = "function",
                    run_keybind_action = "function",
                    bind_keys = "function",
                    unbind_keys = "function",
                    key_held_frames = "function",
                    is_modifier_held = "function",
                    is_shift_delayed_key = "function",
                    ignore_modifiers = "function",
                    release_key = "function"
                 },
                 IInputHandler)
