local IUiElement = require("api.gui.IUiElement")
local IFocusable = require("api.gui.IFocusable")

return interface("IUiList",
                 {
                    selected_item = "function"
                    items = "table",
                    select_next = "function",
                    select_previous = "function",
                 },
                 {IUiElement, IFocusable})
