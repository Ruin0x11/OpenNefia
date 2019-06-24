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
                    can_choose = "function",
                    get_item_text = "function",
                    choose = "function",
                    on_choose = "function",
                    on_select = "function",

                    iter = "function",
                    iter_all_pages = { type = "function", default = function(self) return self:iter() end },
                 },
                 ISettable)
