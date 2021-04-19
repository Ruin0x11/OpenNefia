local IItemMeleeWeapon = require("mod.elona.api.aspect.IItemMeleeWeapon")

local ItemMeleeWeaponAspect = class.class("ItemMeleeWeaponAspect", IItemMeleeWeapon)

function ItemMeleeWeaponAspect:init(item, params)
   self.dice_x = params.dice_x or 0
   self.dice_y = params.dice_y or 0
   self.pierce_rate = params.pierce_rate or 0
   self.skill = params.skill or "elona.martial_arts"
end

function ItemMeleeWeaponAspect:is_active(item)
   return item:is_equipped()
      and not item:is_equipped_at("elona.ranged")
      and not item:is_equipped_at("elona.ammo")
      and item:get_aspect(IItemMeleeWeapon)
end

return ItemMeleeWeaponAspect
