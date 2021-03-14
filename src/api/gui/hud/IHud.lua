local IDrawLayer = require("api.gui.IDrawLayer")

return class.interface("IHud",
                 {
                    refresh = "function",
                 },
                 { IDrawLayer })
