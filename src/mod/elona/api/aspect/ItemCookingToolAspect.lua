local IItemCookingTool = require("mod.elona.api.aspect.IItemCookingTool")

local ItemCookingToolAspect = class.class("ItemCookingToolAspect", IItemCookingTool)

function ItemCookingToolAspect:init(item, params)
   self.cooking_quality = params.cooking_quality or 0
end

return ItemCookingToolAspect
