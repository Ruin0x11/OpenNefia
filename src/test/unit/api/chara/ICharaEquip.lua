local Chara = require("api.Chara")
local IOwned = require("api.IOwned")
local Assert = require("api.test.Assert")
local ICharaEquip = require("api.chara.ICharaEquip")
local Item = require("api.Item")

local function enchantless_item(id)
   local item = Item.create(id, nil, nil, {ownerless=true})

   local filter = function(enc) return enc.source ~= "item" end
   item:iter_enchantments():filter(filter):each(function(enc) assert(item:remove_enchantment(enc)) end)

   item:refresh()
   Assert.eq(0, item:iter_enchantments(item):length())
   return item
end

local function stripped_chara(id)
   local chara = Chara.create(id, nil, nil, {ownerless=true})
   chara:iter_items():each(IOwned.remove_ownership)
   return chara
end

function test_ICharaEquip_iter_merged_enchantments__single()
   local chara = stripped_chara("elona.the_leopard_warrior")

   Assert.eq(0, ICharaEquip.iter_merged_enchantments(chara):length())

   local item = enchantless_item("elona.long_bow")
   Assert.is_truthy(chara:equip_item(item, true))
   Assert.eq(0, ICharaEquip.iter_merged_enchantments(chara):length())

   do
      item:add_enchantment("elona.absorb_mana", 20, {})

      local iter = ICharaEquip.iter_merged_enchantments(chara)
      Assert.eq(1, iter:length())

      local enc, enc_item = iter:nth(1)
      Assert.eq(20, enc.total_power)
      Assert.eq("elona.absorb_mana", enc._id)
      Assert.eq("elona.absorb_mana", enc.proto._id)
      Assert.eq(item, enc_item)
   end

   do
      item:add_enchantment("elona.absorb_mana", 15, {})

      local iter = ICharaEquip.iter_merged_enchantments(chara)
      Assert.eq(1, iter:length())

      local enc, enc_item = iter:nth(1)
      Assert.eq(27, enc.total_power)
      Assert.eq("elona.absorb_mana", enc._id)
      Assert.eq(item, enc_item)
   end

   do
      item:add_enchantment("elona.modify_attribute", 20, {skill_id="elona.stat_strength"})

      local iter = ICharaEquip.iter_merged_enchantments(chara)
      Assert.eq(2, iter:length())

      local enc, enc_item = iter:nth(1)
      Assert.eq(20, enc.total_power)
      Assert.eq("elona.modify_attribute", enc._id)
      Assert.eq("elona.stat_strength", enc.params.skill_id)
      Assert.eq(item, enc_item)

      enc, enc_item = iter:nth(2)
      Assert.eq(27, enc.total_power)
      Assert.eq("elona.absorb_mana", enc._id)
      Assert.eq(item, enc_item)
   end

   Assert.is_truthy(chara:unequip_item(item))
   Assert.eq(0, ICharaEquip.iter_merged_enchantments(chara):length())
end

function test_ICharaEquip_iter_merged_enchantments__multiple()
   local chara = stripped_chara("elona.the_leopard_warrior")

   Assert.eq(0, ICharaEquip.iter_merged_enchantments(chara):length())

   local item1 = enchantless_item("elona.long_bow")
   Assert.is_truthy(chara:equip_item(item1, true))
   item1:add_enchantment("elona.absorb_mana", 20, {})
   item1:add_enchantment("elona.absorb_mana", 15, {})
   item1:add_enchantment("elona.res_fear", 30, {})

   local item2 = enchantless_item("elona.dagger")
   Assert.is_truthy(chara:equip_item(item2, true))
   item2:add_enchantment("elona.modify_skill", 40, {skill_id="elona.weight_lifting"})
   item2:add_enchantment("elona.modify_skill", 25, {skill_id="elona.weight_lifting"})
   item2:add_enchantment("elona.res_sleep", 50, {})

   do
      local iter = ICharaEquip.iter_merged_enchantments(chara)
      Assert.eq(4, iter:length())

      local enc, enc_item = iter:nth(1)
      Assert.eq(30, enc.total_power)
      Assert.eq("elona.res_fear", enc._id)
      Assert.eq(item1, enc_item)

      enc, enc_item = iter:nth(2)
      Assert.eq(27, enc.total_power)
      Assert.eq("elona.absorb_mana", enc._id)
      Assert.eq(item1, enc_item)

      enc, enc_item = iter:nth(3)
      Assert.eq(52, enc.total_power)
      Assert.eq("elona.modify_skill", enc._id)
      Assert.eq("elona.weight_lifting", enc.params.skill_id)
      Assert.eq(item2, enc_item)

      enc, enc_item = iter:nth(4)
      Assert.eq(50, enc.total_power)
      Assert.eq("elona.res_sleep", enc._id)
      Assert.eq(item2, enc_item)
   end

   do
      Assert.is_truthy(chara:unequip_item(item1))
      local iter = ICharaEquip.iter_merged_enchantments(chara)
      Assert.eq(2, iter:length())

      local enc, enc_item = iter:nth(1)
      Assert.eq(52, enc.total_power)
      Assert.eq("elona.modify_skill", enc._id)
      Assert.eq("elona.weight_lifting", enc.params.skill_id)
      Assert.eq(item2, enc_item)

      enc, enc_item = iter:nth(2)
      Assert.eq(50, enc.total_power)
      Assert.eq("elona.res_sleep", enc._id)
      Assert.eq(item2, enc_item)
   end

   Assert.is_truthy(chara:unequip_item(item2))
   Assert.eq(0, ICharaEquip.iter_merged_enchantments(chara):length())
end