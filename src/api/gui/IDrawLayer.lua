local IUiElement = require("api.gui.IUiElement")

return class.interface("IDrawLayer",
                 {
                    reset = "function",
                    on_theme_switched = "function",
                    default_z_order = "function",
                 },
                 IUiElement)
