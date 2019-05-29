local IUiList = require("api.gui.IUiList")

return interface("IUiPages",
                 {
                    select_page = "function",
                    next_page = "function",
                    previous_page = "function",
                    page = "number"
                 },
                 IUiList)
