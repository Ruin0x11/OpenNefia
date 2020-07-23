local IUiElement = require("api.gui.IUiElement")

return class.interface("IDrawLayer",
                 {
                    reset = "function",
                    on_theme_switched = "function",
                 },
                 IUiElement)
