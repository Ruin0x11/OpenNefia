local IItemBait = require("mod.elona.api.aspect.IItemBait")

local ItemBaitAspect = class.class("ItemBaitAspect", { IItemBait })

function ItemBaitAspect:init(item, params)
   self.bait_type = params.bait_type or nil
end

return ItemBaitAspect
