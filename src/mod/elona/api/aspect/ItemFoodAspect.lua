local IItemFood = require("mod.elona.api.aspect.IItemFood")

local ItemFoodAspect = class.class("ItemFoodAspect", IItemFood)

function ItemFoodAspect:init(item, params)
   if params.food_type then
      data["elona.food_type"]:ensure(params.food_type)
   end

   self.food_quality = params.food_quality or 0
   self.food_type = params.food_type or nil
   self.nutrition = params.nutrition or nil
   self.exp_gains = params.exp_gains or nil
   self.spoilage_date = params.spoilage_date or 0
   self.spoilage_hours = params.spoilage_hours or nil
end

return ItemFoodAspect
