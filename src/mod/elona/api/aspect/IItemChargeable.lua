local IAspect = require("api.IAspect")
local IChargeable = require("mod.elona.api.aspect.IChargeable")

local IItemChargeable = class.interface("IItemChargeable", {}, { IAspect, IChargeable })

IItemChargeable.default_impl = "mod.elona.api.aspect.ItemChargeableAspect"

function IItemChargeable:localize_action()
   return "base:aspect._.elona.IItemChargeable.action_name"
end

return IItemChargeable
