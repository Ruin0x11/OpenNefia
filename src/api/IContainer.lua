local ILocation = require("api.ILocation")

return class.interface("IContainer",
                       {
                          get_max_capacity = "function",
                          set_max_capacity = "function",
                          get_max_item_weight = "function",
                          set_max_item_weight = "function",
                       },
                       {ILocation})
