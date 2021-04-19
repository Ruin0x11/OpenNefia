local IItemFishingPole = require("mod.elona.api.aspect.IItemFishingPole")

local ItemFishingPoleAspect = class.class("ItemFishingPoleAspect", IItemFishingPole)

function ItemFishingPoleAspect:init(item, params)
   self.bait_type = params.bait_type or nil
   self.bait_amount = params.bait_amount or 0
end

return ItemFishingPoleAspect
