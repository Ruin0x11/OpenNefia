local IAspect = require("api.IAspect")

local IItemSeed = class.interface("IItemSeed", { plant_id = "string" }, { IAspect })

IItemSeed.default_impl = "mod.elona.api.aspect.ItemSeedAspect"

function IItemSeed:localize_action()
   return "base:aspect._.elona.IItemSeed.action_name"
end

return IItemSeed
