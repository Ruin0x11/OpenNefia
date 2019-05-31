local ISettable = require("api.gui.ISettable")

return interface("IList",
                 {
                    changed = "boolean",
                    selected = "number",
                    chosen = "boolean",
                    items = "table",
                    selected_item = "function",
                    select = "function",
                    select_next = "function",
                    select_previous = "function",
                    can_select = "function",
                    get_item_text = "function",
                    choose = "function",
                 },
                 ISettable)
