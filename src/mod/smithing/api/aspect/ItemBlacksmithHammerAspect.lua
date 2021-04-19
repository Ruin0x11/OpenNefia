local IItemBlacksmithHammer = require("mod.smithing.api.aspect.IItemBlacksmithHammer")

local ItemBlacksmithHammerAspect = class.class("ItemBlacksmithHammerAspect", { IItemBlacksmithHammer })

function ItemBlacksmithHammerAspect:init(item, params)
   self.hammer_level = math.max(params.hammer_level or 1, 1)
   self.hammer_experience = math.max(params.hammer_experience or 0, 0)
   self.total_uses = math.max(params.total_uses or 0, 0)
end

return ItemBlacksmithHammerAspect
