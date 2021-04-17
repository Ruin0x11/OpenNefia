local IAspect = require("api.IAspect")

local IItemSeed = class.interface("IItemSeed", { plant_id = "string" }, { IAspect })

IItemSeed.default_impl = "mod.elona.api.aspect.ItemSeedAspect"

return IItemSeed
