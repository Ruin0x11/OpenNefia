local IItemRangedWeapon = require("mod.elona.api.aspect.IItemRangedWeapon")
local IItemAmmo = require("mod.elona.api.aspect.IItemAmmo")

local ItemRangedWeaponAspect = class.class("ItemRangedWeaponAspect", IItemRangedWeapon)

function ItemRangedWeaponAspect:init(item, params)
   self.dice_x = params.dice_x or 0
   self.dice_y = params.dice_y or 0
   self.pierce_rate = params.pierce_rate or 0
   self.skill = params.skill or "elona.throwing"
   self.effective_range = params.effective_range or {}
end

function ItemRangedWeaponAspect:is_active(item)
   return item:is_equipped_at("elona.ranged")
      and item:get_aspect(IItemRangedWeapon)
end

function ItemRangedWeaponAspect:can_use_without_ammo(ranged)
   return self:calc(ranged, "skill") == "elona.throwing"
end

function ItemRangedWeaponAspect:can_use_with_ammo(ranged, ammo)
   local ranged_skill = self:calc(ranged, "skill")
   local ammo_skill = ammo:calc_aspect(IItemAmmo, "skill")
   return ranged_skill and ammo_skill and ranged_skill == ammo_skill
end

function ItemRangedWeaponAspect:calc_effective_range(item, dist)
   dist = math.max(math.floor(dist), 0)
   local result
   local effective_range = self:calc(item, "effective_range")
   if type(effective_range) == "table" then
      result = effective_range[dist]
      if not result then
         -- vanilla compat
         result = effective_range[math.min(dist, 9)]
      end
   elseif type(effective_range) == "number" then
      result = effective_range
   end
   return result or 100
end

return ItemRangedWeaponAspect
