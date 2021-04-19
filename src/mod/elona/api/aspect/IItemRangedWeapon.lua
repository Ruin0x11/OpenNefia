local IAspect = require("api.IAspect")
local IItemWeapon = require("mod.elona.api.aspect.IItemWeapon")

local IItemRangedWeapon = class.interface("IItemRangedWeapon", {
                                             effective_range = "table"
                                                               }, { IAspect, IItemWeapon })

IItemRangedWeapon.default_impl = "mod.elona.api.aspect.ItemRangedWeaponAspect"

function IItemRangedWeapon:is_active(item)
   return true
end

function IItemRangedWeapon:can_use_without_ammo(item)
   return true
end

function IItemRangedWeapon:can_use_with_ammo(item, ammo)
   return true
end

function IItemRangedWeapon:calc_effective_range(item, dist)
   return 100
end

function IItemRangedWeapon:calc_anim_chip_and_sound(weapon)
   return weapon:calc("image"),
          weapon:calc("color") or {255, 255, 255},
          "base.throw1"
end

return IItemRangedWeapon
