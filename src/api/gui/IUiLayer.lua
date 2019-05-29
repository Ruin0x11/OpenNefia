local IUiElement = require("api.gui.IUiElement")
local IFocusable = require("api.gui.IFocusable")

return interface("IUiLayer",
                 { layout = "function" },
                 { IUiElement, IFocusable })
