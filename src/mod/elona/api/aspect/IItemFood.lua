local IAspect = require("api.IAspect")
local World = require("api.World")

local IItemFood = class.interface("IItemFood",
                                  {
                                     food_type = { type = "string", optional = true },
                                     food_quality = "number",
                                     nutrition = { type = "number", optional = true },
                                     exp_gains = { type = "table", optional = true },
                                     spoilage_hours = { type = "number", optional = true },
                                     spoilage_date = "number",
                                  },
                                  { IAspect })

IItemFood.default_impl = "mod.elona.api.aspect.ItemFoodAspect"

function IItemFood:can_rot(item)
   return self:calc(item, "spoilage_date") > 0
end

function IItemFood:is_rotten(item)
   return self:calc(item, "spoilage_date") < 0
end

function IItemFood:is_about_to_rot(item, hours)
   return self:can_rot(item)
      and self:calc(item, "spoilage_date") < (hours or World.date_hours())
end

function IItemFood:is_cooked(item)
   return self:calc(item, "food_quality") > 0
end

function IItemFood:can_cook(item)
   return not self:is_cooked(item) and (not not self:calc(item, "food_type"))
end

function IItemFood:rot(item)
   self.spoilage_date = -1
   item.image = "elona.item_rotten_food"
end

return IItemFood
