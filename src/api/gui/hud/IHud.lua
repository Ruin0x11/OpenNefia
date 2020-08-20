local IUiElement = require("api.gui.IUiElement")

return class.interface("IHud",
                 {
                    refresh = "function",
                 },
                 IUiElement)
