local IItemGaroksHammer = require("mod.elona.api.aspect.IItemGaroksHammer")
local Rand = require("api.Rand")

local ItemGaroksHammerAspect = class.class("ItemGaroksHammerAspect", { IItemGaroksHammer })

function ItemGaroksHammerAspect:init(item, params)
   self.seed = params.seed or (Rand.rnd(20000) + 1)
end

return ItemGaroksHammerAspect
