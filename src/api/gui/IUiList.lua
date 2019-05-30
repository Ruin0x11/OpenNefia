local IUiElement = require("api.gui.IUiElement")
local IFocusable = require("api.gui.IFocusable")
local ISettable = require("api.gui.ISettable")

return interface("IUiList",
                 {
                    changed = "boolean",
                    selected = "number",
                    items = "table",
                    selected_item = "function",
                    select = "function",
                    select_next = "function",
                    select_previous = "function",
                    can_select = "function",
                    draw_item = "function",
                    get_item_text = "function",
                    choose = "function",
                 },
                 {IUiElement, IFocusable, ISettable})
