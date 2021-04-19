local IItemAmmo = require("mod.elona.api.aspect.IItemAmmo")

local ItemAmmoAspect = class.class("ItemAmmoAspect", IItemAmmo)

function ItemAmmoAspect:init(item, params)
   self.dice_x = params.dice_x or 0
   self.dice_y = params.dice_y or 0
   self.skill = params.skill or "elona.bow"
end

return ItemAmmoAspect
