local IUiLayer = require("api.gui.IUiLayer")

return interface("ICharaMakeSection",
                 {
                    caption = "string",
                    get_result = "function",
                 },
                 { IUiLayer, IKeyInput })
