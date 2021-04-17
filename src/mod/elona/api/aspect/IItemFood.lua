local IAspect = require("api.IAspect")

local IItemFood = class.interface("IItemFood",
                                  {
                                     food_type = { type = "string", optional = true },
                                     food_quality = "number",
                                     nutrition = { type = "number", optional = true },
                                     exp_gains = { type = "table", optional = true },
                                  },
                                  { IAspect })

IItemFood.default_impl = "mod.elona.api.aspect.ItemFoodAspect"

return IItemFood
