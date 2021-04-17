local IAspect = require("api.IAspect")

local IItemFromChara = class.interface("IItemFromChara", { chara_id = { type = "string", optional = true } }, { IAspect })

IItemFromChara.default_impl = "mod.elona.api.aspect.ItemFromCharaAspect"

return IItemFromChara
