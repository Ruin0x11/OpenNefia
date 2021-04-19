local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")
local IItemMeleeWeapon = require("mod.elona.api.aspect.IItemMeleeWeapon")
local IItemRangedWeapon = require("mod.elona.api.aspect.IItemRangedWeapon")
local IItemAmmo = require("mod.elona.api.aspect.IItemAmmo")

local EquipRules = {}

function EquipRules.is_melee_weapon(item)
   local melee = item:get_aspect(IItemMeleeWeapon)
   return melee and melee:is_active(item)
end

function EquipRules.is_ranged_weapon(item)
   local ranged = item:get_aspect(IItemRangedWeapon)
   return ranged and ranged:is_active(item)
end

function EquipRules.is_ammo(item)
   local ammo = item:get_aspect(IItemAmmo)
   return ammo and ammo:is_active(item)
end

function EquipRules.is_armor(item)
   return item:get_aspect(IItemEquipment)
      and not EquipRules.is_melee_weapon(item)
      and not EquipRules.is_ranged_weapon(item)
end

return EquipRules
