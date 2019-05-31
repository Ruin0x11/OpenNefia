local IDrawable = require("api.gui.IDrawable")
local IFocusable = require("api.gui.IFocusable")

return interface("IUiLayer",
                 {
                    relayout = "function",
                    query = "function",
                 },
                 { IDrawable, IFocusable })
