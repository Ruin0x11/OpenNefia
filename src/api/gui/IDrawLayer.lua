local IUiElement = require("api.gui.IUiElement")
local ILayer = require("api.gui.ILayer")

return class.interface("IDrawLayer",
                 {
                    reset = "function",
                 },
                 { ILayer, IUiElement })
