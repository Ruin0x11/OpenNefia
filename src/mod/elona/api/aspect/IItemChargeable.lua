local IChargeable = require("mod.elona.api.aspect.IChargeable")

local IItemChargeable = class.interface("IItemChargeable", {}, { IChargeable })

IItemChargeable.default_impl = "mod.elona.api.aspect.ItemChargeableAspect"

return IItemChargeable
