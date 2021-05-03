local IItemRod = require("mod.elona.api.aspect.IItemRod")
local IChargeable = require("mod.elona.api.aspect.IChargeable")

local ItemRodAspect = class.class("ItemRodAspect", IItemRod)

function ItemRodAspect:init(item, params)
   IChargeable.init(self, item, params)

   self.effect_id = params.effect_id or nil
   self.effect_power = params.effect_power or 0
   self.is_zap_always_successful = params.is_zap_always_successful or nil
end

return ItemRodAspect
