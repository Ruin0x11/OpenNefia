local IDrawable = require("api.gui.IDrawable")

return interface("IUiElement",
                 {
                    x = "number",
                    y = "number",
                    relayout = "function",
                 },
                 IDrawable)
