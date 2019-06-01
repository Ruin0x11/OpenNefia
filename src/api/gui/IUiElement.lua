local IDrawable = require("api.gui.IDrawable")

return interface("IUiElement",
                 {
                    x = { default = 0 },
                    y = { default = 0 },
                    width = { default = 0 },
                    height = { default = 0 },
                    relayout = "function",
                 },
                 IDrawable)
