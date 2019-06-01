local IUiLayer = require("api.gui.IUiLayer")

return interface("ICharaMakeSection",
                 {
                    caption = "string",
                    on_charamake_finish = "function",
                 },
                 { IUiLayer })
