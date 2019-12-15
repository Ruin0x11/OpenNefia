local IUiLayer = require("api.gui.IUiLayer")

return class.interface("IHud",
                 {
                    set_date = "function",
                    set_target = "function",
                    register_widget = "function",
                    find_widget = "function",
                 },
                 IUiLayer)
