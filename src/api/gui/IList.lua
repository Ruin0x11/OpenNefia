local ISettable = require("api.gui.ISettable")

return class.interface("IList",
                 {
                    changed = "boolean",
                    selected = "number", -- TODO replace with selected_index()
                    chosen = "boolean",
                    items = "table",
                    get = "function",
                    get_current_page = { type = "function", default = function(self, index) return self:get(index) end },
                    selected_item = "function",
                    selected_index = "function",
                    select = "function",
                    select_next = "function",
                    select_previous = { type = "function", default = function(self, delta) self:select_next(-(delta or 1)) end },
                    can_select = "function",
                    can_choose = "function",
                    get_item_text = "function",
                    choose = "function",
                    on_choose = "function",
                    on_select = "function",

                    len = "function",
                    iter = "function",
                    iter_all_pages = { type = "function", default = function(self) return self:iter() end },
                 },
                 ISettable)
