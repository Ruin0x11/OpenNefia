local IItemAncientBook = require("mod.elona.api.aspect.IItemAncientBook")
local IChargeable = require("mod.elona.api.aspect.IChargeable")

local ItemAncientBookAspect = class.class("ItemAncientBookAspect", IItemAncientBook)

function ItemAncientBookAspect:init(item, params)
   if params.can_be_recharged == nil then
      params.can_be_recharged = false
   end
   IChargeable.init(self, item, params)

   self.difficulty = params.difficulty or 0
   if self.is_decoded == nil then
      self.is_decoded = false
   end
end

return ItemAncientBookAspect
