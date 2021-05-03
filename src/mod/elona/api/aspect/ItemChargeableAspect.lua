local IItemChargeable = require("mod.elona.api.aspect.IItemChargeable")
local IChargeable = require("mod.elona.api.aspect.IChargeable")

local ItemChargeableAspect = class.class("ItemChargeableAspect", IItemChargeable)

function ItemChargeableAspect:init(item, params)
   IChargeable.init(self, item, params)
end

return ItemChargeableAspect
