local IItemRangedWeapon = require("mod.elona.api.aspect.IItemRangedWeapon")

local ItemRangedWeaponAspect = class.class("ItemRangedWeaponAspect", IItemRangedWeapon)

function ItemRangedWeaponAspect:init(item, params)
   self.dice_x = params.dice_x or 0
   self.dice_y = params.dice_y or 0
   self.pierce_rate = params.pierce_rate or 0
   self.skill = params.skill or "elona.throwing"
   self.effective_range = params.effective_range or {}
end

return ItemRangedWeaponAspect
