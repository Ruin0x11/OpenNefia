local IItemMeleeWeapon = require("mod.elona.api.aspect.IItemMeleeWeapon")

local ItemMeleeWeaponAspect = class.class("ItemMeleeWeaponAspect", IItemMeleeWeapon)

function ItemMeleeWeaponAspect:init(item, params)
   self.dice_x = params.dice_x or 0
   self.dice_y = params.dice_y or 0
   self.pierce_rate = params.pierce_rate or 0
   self.skill = params.skill or "elona.martial_arts"
end

return ItemMeleeWeaponAspect
