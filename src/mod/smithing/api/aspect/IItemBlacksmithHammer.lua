local IAspect = require("api.IAspect")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")

local IItemBlacksmithHammer = class.interface("IItemBlacksmithHammer",
                                  {
                                     hammer_level = "number",
                                     hammer_experience = "number",
                                     total_uses = "number",
                                  },
                                  { IAspect, IItemUseable })

IItemBlacksmithHammer.default_impl = "mod.smithing.api.aspect.ItemBlacksmithHammerAspect"

function IItemBlacksmithHammer:can_upgrade(item)
   return false
end

function IItemBlacksmithHammer:calc_required_exp(item)
   return 1
end

function IItemBlacksmithHammer:gain_level(item)
end

function IItemBlacksmithHammer:exp_percent(item)
   return (self.hammer_experience * 100.0) / self:calc_required_exp(item)
end

function IItemBlacksmithHammer:calc_item_generation_seed(item)
   return 0
end

function IItemBlacksmithHammer:calc_equipment_upgrade_power(item, target)
   return 0
end


function IItemBlacksmithHammer:localize_action()
   return "base:aspect._.elona.IItemBlacksmithHammer.action_name"
end

return IItemBlacksmithHammer
