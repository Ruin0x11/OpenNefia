local IItemAmmo = require("mod.elona.api.aspect.IItemAmmo")

local ItemAmmoAspect = class.class("ItemAmmoAspect", IItemAmmo)

function ItemAmmoAspect:init(item, params)
   self.dice_x = params.dice_x or 0
   self.dice_y = params.dice_y or 0
   self.skill = params.skill or "elona.bow"
end

function ItemAmmoAspect:is_active(item)
   return item:is_equipped_at("elona.ammo")
      and item:get_aspect(IItemAmmo)
end

function ItemAmmoAspect:is_compatible_with(ammo, ranged_weapon)
end

return ItemAmmoAspect
