local IAspect = require("api.IAspect")
local IItemWeapon = require("mod.elona.api.aspect.IItemWeapon")

local IItemMeleeWeapon = class.interface("IItemMeleeWeapon", {}, { IAspect, IItemWeapon })

IItemMeleeWeapon.default_impl = "mod.elona.api.aspect.ItemMeleeWeaponAspect"

function IItemMeleeWeapon:is_active(item)
   return item:is_equipped()
      and not item:is_equipped_at("elona.ranged")
      and not item:is_equipped_at("elona.ammo")
      and item:get_aspect(IItemMeleeWeapon)
end

return IItemMeleeWeapon
