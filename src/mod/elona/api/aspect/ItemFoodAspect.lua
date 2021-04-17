local IItemFood = require("mod.elona.api.aspect.IItemFood")

local ItemFoodAspect = class.class("ItemFoodAspect", IItemFood)

function ItemFoodAspect:init(item, params)
   self.food_quality = params.food_quality or 0
   self.food_type = params.food_type or nil
   self.nutrition = params.nutrition or nil
   self.exp_gains = params.exp_gains or nil
end

return ItemFoodAspect
