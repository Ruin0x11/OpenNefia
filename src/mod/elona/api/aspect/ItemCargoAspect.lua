local IItemCargo = require("mod.elona.api.aspect.IItemCargo")

local ItemCargoAspect = class.class("ItemCargoAspect", IItemCargo)

function ItemCargoAspect:init(item, params)
   self.cargo_weight = params.cargo_weight or 0
   self.cargo_quality = params.cargo_quality or 0
end

return ItemCargoAspect
