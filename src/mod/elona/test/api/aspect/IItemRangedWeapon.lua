local IItemRangedWeapon = require("mod.elona.api.aspect.IItemRangedWeapon")
local Item = require("api.Item")
local Assert = require("api.test.Assert")

function test_IItemRangedWeapon_can_use_with_ammo()
   local weapon = Item.create("elona.long_bow", nil, nil, {ownerless=true})
   local arrow = Item.create("elona.arrow", nil, nil, {ownerless=true})
   local bullet = Item.create("elona.bullet", nil, nil, {ownerless=true})
   local aspect = weapon:get_aspect(IItemRangedWeapon)

   Assert.eq(false, aspect:can_use_without_ammo(weapon))
   Assert.eq(true, aspect:can_use_with_ammo(weapon, arrow))
   Assert.eq(false, aspect:can_use_with_ammo(weapon, bullet))
end

function test_IItemRangedWeapon_can_use_without_ammo()
   local weapon = Item.create("elona.stone", nil, nil, {ownerless=true})
   local ammo = Item.create("elona.bullet", nil, nil, {ownerless=true})
   local aspect = weapon:get_aspect(IItemRangedWeapon)

   Assert.eq(true, aspect:can_use_without_ammo(weapon))
   Assert.eq(false, aspect:can_use_with_ammo(weapon, ammo))
end

function test_IItemRangedWeapon_calc_effective_range()
   local weapon = Item.create("elona.stone", nil, nil, {ownerless=true})
   local aspect = weapon:get_aspect(IItemRangedWeapon)

   Assert.eq(60, aspect:calc_effective_range(weapon, 1))
   Assert.eq(100, aspect:calc_effective_range(weapon, 2))
   Assert.eq(70, aspect:calc_effective_range(weapon, 3))
   Assert.eq(20, aspect:calc_effective_range(weapon, 100))
end
