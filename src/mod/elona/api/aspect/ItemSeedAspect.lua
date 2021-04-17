local IItemSeed = require("mod.elona.api.aspect.IItemSeed")

local ItemSeedAspect = class.class("ItemSeedAspect", IItemSeed)

function ItemSeedAspect:init(item, params)
   self.plant_id = params.plant_id
end

return ItemSeedAspect
