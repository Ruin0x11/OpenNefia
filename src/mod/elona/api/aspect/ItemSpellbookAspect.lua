local IItemSpellbook = require("mod.elona.api.aspect.IItemSpellbook")
local IChargeable = require("mod.elona.api.aspect.IChargeable")

local ItemSpellbookAspect = class.class("ItemSpellbookAspect", IItemSpellbook)

function ItemSpellbookAspect:init(item, params)
   IChargeable.init(self, item, params)

   self.skill_id = params.skill_id or nil
end

return ItemSpellbookAspect
