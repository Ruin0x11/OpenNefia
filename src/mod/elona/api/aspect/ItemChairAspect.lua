local IItemChair = require("mod.elona.api.aspect.IItemChair")

local ItemChairAspect = class.class("ItemChairAspect", { IItemChair })

function ItemChairAspect:init(item, params)
   self.chair_type = params.chair_type or "free"
end

return ItemChairAspect
