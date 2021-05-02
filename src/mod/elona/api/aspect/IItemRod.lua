local IAspect = require("api.IAspect")
local IItemZappable = require("mod.elona.api.aspect.IItemZappable")
local IChargeable = require("mod.elona.api.aspect.IChargeable")

local IItemRod = class.interface("IItemRod",
                                  {
                                     effects = "table"
                                  },
                                  { IAspect, IChargeable, IItemZappable })

IItemRod.default_impl = "mod.elona.api.aspect.ItemRodAspect"

function IItemRod:localize_action()
   return "base:aspect._.elona.IItemRod.action_name"
end

function IItemRod:on_zap(item, params)

   return "turn_end"
end

return IItemRod
