local ILocation = require("api.ILocation")

return interface("ITypedLocation",
                 {
                    iter_type = "function",
                    iter_type_at_pos = "function",
                    get_object_of_type = "function",
                 },
                 ILocation)
