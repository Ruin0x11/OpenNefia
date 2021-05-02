local IAspect = require("api.IAspect")
local IItemZappable = require("mod.elona.api.aspect.IItemZappable")
local IChargeable = require("mod.elona.api.aspect.IChargeable")

local IItemRod = class.interface("IItemRod",
                                  {
                                     effect_id = "string",
                                     effect_power = "number"
                                  },
                                  { IAspect, IChargeable, IItemZappable })

IItemRod.default_impl = "mod.elona.api.aspect.ItemRodAspect"

function IItemRod:localize_action()
   return "base:aspect._.elona.IItemRod.action_name"
end

function IItemRod:on_zap(item, params)
   local effect_id = self:calc(item, "effect_id")
   local effect_power = self:calc(item, "effect_power")
   local ElonaMagic = require("mod.elona.api.ElonaMagic")
   return ElonaMagic.zap_rod(item, effect_id, effect_power, params)
end

return IItemRod
