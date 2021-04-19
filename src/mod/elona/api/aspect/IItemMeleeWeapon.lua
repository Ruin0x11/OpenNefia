local IAspect = require("api.IAspect")
local IItemWeapon = require("mod.elona.api.aspect.IItemWeapon")

local IItemMeleeWeapon = class.interface("IItemMeleeWeapon", {}, { IAspect, IItemWeapon })

IItemMeleeWeapon.default_impl = "mod.elona.api.aspect.ItemMeleeWeaponAspect"

function IItemMeleeWeapon:is_active(chara)
   return true
end

return IItemMeleeWeapon
