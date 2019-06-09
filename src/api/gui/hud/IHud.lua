local IUiElement = require("api.gui.IUiElement")

return interface("IHud",
                 {
                    set_date = "function",
                    set_target = "function",
                    register_widget = "function",
                    find_widget = "function",
                 },
                 IUiElement)
