local InstancedEnchantment = require("api.item.InstancedEnchantment")
local Assert = require("api.test.Assert")

function test_InstancedEnchantment_is_same_as__no_params()
   local enc1 = InstancedEnchantment:new("elona.res_curse", 20)
   local enc2 = InstancedEnchantment:new("elona.res_curse", 15)

   Assert.eq(true, enc1:is_same_as(enc2))
   Assert.eq(true, enc2:is_same_as(enc1))
end

function test_InstancedEnchantment_is_same_as__with_params()
   local enc1 = InstancedEnchantment:new("elona.modify_attribute", 20, {skill_id="elona.stat_strength"})

   do
      local enc2 = InstancedEnchantment:new("elona.modify_attribute", 15, {skill_id="elona.stat_strength"})

      Assert.eq(true, enc1:is_same_as(enc2))
      Assert.eq(true, enc2:is_same_as(enc1))
   end

   do
      local enc2 = InstancedEnchantment:new("elona.modify_attribute", 15, {skill_id="elona.stat_strength"})

      Assert.eq(false, enc1:is_same_as(enc2))
      Assert.eq(false, enc2:is_same_as(enc1))
   end
end

function test_InstancedEnchantment_is_same_as__custom_compare()
   local enc1 = InstancedEnchantment:new("elona.ammo", 20, {ammo_enchantment_id="elona.rapid"})

   do
      local enc2 = InstancedEnchantment:new("elona.ammo", 15, {ammo_enchantment_id="elona.bomb"})

      Assert.eq(false, enc1:is_same_as(enc2))
      Assert.eq(false, enc2:is_same_as(enc1))
   end

   do
      local enc2 = InstancedEnchantment:new("elona.ammo", 20, {ammo_enchantment_id="elona.rapid"})

      Assert.eq(true, enc1:is_same_as(enc2))
      Assert.eq(true, enc2:is_same_as(enc1))

      enc1.params.ammo_current = 10
      enc2.params.ammo_current = 0
      Assert.eq(true, enc1:is_same_as(enc2))
      Assert.eq(true, enc2:is_same_as(enc1))
   end
end
