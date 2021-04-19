local ICharaSandBag = require("mod.elona.api.aspect.ICharaSandBag")

local CharaSandBagAspect = class.class("CharaSandBagAspect", ICharaSandBag)

function CharaSandBagAspect:init(chara, params)
   self.is_hung_on_sand_bag = params.is_hung_on_sand_bag or false

   if self.is_hung_on_sand_bag then
      self:hang_on_sand_bag(chara)
   end
end

return CharaSandBagAspect
