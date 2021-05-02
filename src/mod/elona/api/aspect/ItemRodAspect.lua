local IItemRod = require("mod.elona.api.aspect.IItemRod")

local ItemRodAspect = class.class("ItemRodAspect", IItemRod)

function ItemRodAspect:init(item, params)
   if type(params.charges) == "function" then
      self.charges = params.charges(item)
   elseif type(params.charges) == "number" then
      self.charges = params.charges
   else
      self.charges = 0
   end
   self.max_charges = params.max_charges or 0

   self.effect_id = params.effect_id or nil
   self.effect_power = params.effect_power or 0
end

return ItemRodAspect
