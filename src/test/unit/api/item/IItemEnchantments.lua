local Item = require("api.Item")
local IItemEnchantments = require("api.item.IItemEnchantments")
local Assert = require("api.test.Assert")
local data = require("internal.data")
local InstancedEnchantment = require("api.item.InstancedEnchantment")

local function enchantless_item(id)
   local item = Item.create(id, nil, nil, {ownerless=true})

   local filter = function(enc) return enc.source ~= "item" end
   item:iter_enchantments():filter(filter):each(function(enc) assert(item:remove_enchantment(enc)) end)

   item:refresh()
   Assert.eq(0, item:iter_enchantments(item):length())
   return item
end

function test_IItemEnchantment_init__fixed_enchantments()
   local item = enchantless_item("elona.blood_moon")

   Assert.eq(6, IItemEnchantments.iter_enchantments(item):length())
   Assert.eq(6, IItemEnchantments.iter_enchantments(item, nil, nil, "item"):length())
end

function test_IItemEnchantment_add_enchantment_maximum()
   local item = enchantless_item("elona.long_bow")

   for _, skill_id in data["base.skill"]:iter():take(15):extract("_id") do
      Assert.is_truthy(IItemEnchantments.add_enchantment(item, "elona.modify_skill", 20, {skill_id=skill_id}))
   end

   Assert.is_falsy(IItemEnchantments.add_enchantment(item, "elona.res_fear", 20, {}))
end

function test_IItemEnchantment_remove_enchantment()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.iter_enchantments(item):length())

   local enc = item:add_enchantment("elona.res_curse", 20, "randomized")
   Assert.eq(1, IItemEnchantments.iter_enchantments(item):length())

   Assert.is_truthy(item:remove_enchantment(enc))
   Assert.eq(0, IItemEnchantments.iter_enchantments(item):length())

   local other_enc = InstancedEnchantment:new("elona.res_curse", 20, "randomized")
   Assert.is_falsy(item:remove_enchantment(other_enc))
end

function test_IItemEnchantment_remove_enchantment__source()
   local item = enchantless_item("elona.blood_moon")

   Assert.eq(6, IItemEnchantments.iter_enchantments(item):length())

   item:add_enchantment("elona.absorb_mana", 20, "randomized")
   Assert.eq(7, IItemEnchantments.iter_enchantments(item):length())

   Assert.is_truthy(item:remove_enchantment("elona.absorb_mana"))
   Assert.eq(6, IItemEnchantments.iter_enchantments(item):length())

   Assert.is_falsy(item:remove_enchantment("elona.absorb_mana"))
   Assert.eq(6, IItemEnchantments.iter_enchantments(item):length())

   Assert.is_truthy(item:remove_enchantment("elona.absorb_mana", nil, "item"))
   Assert.eq(5, IItemEnchantments.iter_enchantments(item):length())
end

function test_IItemEnchantment_iter_enchantments()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.iter_enchantments(item):length())

   item:add_enchantment("elona.res_curse", 20, "randomized")

   do
      Assert.eq(1, IItemEnchantments.iter_enchantments(item):length())
      local enc = IItemEnchantments.iter_enchantments(item):nth(1)
      Assert.eq(20, enc.power)
   end

   item:add_enchantment("elona.res_curse", 15, {})

   do
      Assert.eq(2, IItemEnchantments.iter_enchantments(item):length())
      local enc1 = IItemEnchantments.iter_enchantments(item):nth(1)
      local enc2 = IItemEnchantments.iter_enchantments(item):nth(2)
      Assert.eq(20, enc1.power)
      Assert.eq(15, enc2.power)
   end
end

function test_IItemEnchantment_iter__enchantments__id()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.iter_enchantments(item, "elona.res_curse"):length())

   item:add_enchantment("elona.res_curse", 20, "randomized")
   Assert.eq(1, IItemEnchantments.iter_enchantments(item, "elona.res_curse"):length())
   Assert.eq(0, IItemEnchantments.iter_enchantments(item, "elona.res_steal"):length())
end

function test_IItemEnchantment_iter_enchantments__id_params()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.iter_enchantments(item, "elona.modify_attribute", {skill_id="elona.stat_strength"}):length())

   item:add_enchantment("elona.modify_attribute", 20, {skill_id="elona.stat_strength"})
   item:add_enchantment("elona.modify_attribute", 20, {skill_id="elona.stat_perception"})
   item:add_enchantment("elona.modify_attribute", 20, {skill_id="elona.stat_perception"})
   item:add_enchantment("elona.res_curse", 20, "randomized")
   Assert.eq(1, IItemEnchantments.iter_enchantments(item, "elona.modify_attribute", {skill_id="elona.stat_strength"}):length())
   Assert.eq(2, IItemEnchantments.iter_enchantments(item, "elona.modify_attribute", {skill_id="elona.stat_perception"}):length())
   Assert.eq(0, IItemEnchantments.iter_enchantments(item, "elona.modify_attribute", {skill_id="elona.stat_constitution"}):length())
   Assert.eq(3, IItemEnchantments.iter_enchantments(item, "elona.modify_attribute"):length())
   Assert.eq(4, IItemEnchantments.iter_enchantments(item):length())
end

function test_IItemEnchantment_iter_enchantments__source()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())

   item:add_enchantment("elona.res_curse", 20, "randomized", 0, "generated")
   item:add_enchantment("elona.res_curse", 20, "randomized", 0, "ego")
   item:add_enchantment("elona.res_curse", 20, "randomized", 0, "ego")
   Assert.eq(1, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())
   Assert.eq(2, IItemEnchantments.iter_enchantments(item, nil, nil, "ego"):length())
   Assert.eq(0, IItemEnchantments.iter_enchantments(item, nil, nil, "material"):length())
   Assert.eq(3, IItemEnchantments.iter_enchantments(item):length())
end

function test_IItemEnchantment_enchantment_power()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.res_curse"))

   item:add_enchantment("elona.res_curse", 20, "randomized")

   do
      Assert.eq(1, IItemEnchantments.iter_enchantments(item):length())
      Assert.eq(20, IItemEnchantments.enchantment_power(item, "elona.res_curse"))
   end

   item:add_enchantment("elona.res_curse", 15, {})

   do
      Assert.eq(2, IItemEnchantments.iter_enchantments(item):length())
      Assert.eq(35, IItemEnchantments.enchantment_power(item, "elona.res_curse"))
   end
end

function test_IItemEnchantment_add_enchantment__merging()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.res_curse"))

   item:add_enchantment("elona.modify_attribute", 20, {skill_id = "elona.stat_strength"})

   do
      Assert.eq(1, IItemEnchantments.iter_enchantments(item):length())
      Assert.eq(20, IItemEnchantments.enchantment_power(item, "elona.modify_attribute", {skill_id = "elona.stat_strength"}))
   end

   item:add_enchantment("elona.res_curse", 15, {})

   do
      Assert.eq(2, IItemEnchantments.iter_enchantments(item):length())
      Assert.eq(15, IItemEnchantments.enchantment_power(item, "elona.res_curse"))
   end
end

function test_IItemEnchantment_find_enchantment()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(nil, IItemEnchantments.find_enchantment(item, "elona.res_curse"))

   item:add_enchantment("elona.res_curse", 20, {})
   local enc = IItemEnchantments.find_enchantment(item, "elona.res_curse")
   Assert.is_truthy(enc)
   Assert.eq(20, enc.power)
   Assert.eq("elona.res_curse", enc._id)
   Assert.eq(0, table.count(enc.params))

   item:add_enchantment("elona.res_curse", 15, {}, 0, "ego")
   local enc1 = IItemEnchantments.find_enchantment(item, "elona.res_curse")
   Assert.is_truthy(enc1)
   Assert.eq(20, enc1.power)

   local enc2 = IItemEnchantments.find_enchantment(item, "elona.res_curse", nil, "ego")
   Assert.is_truthy(enc2)
   Assert.eq(15, enc2.power)
   Assert.not_eq(enc1, enc2)

   Assert.eq(nil, IItemEnchantments.find_enchantment(item, "elona.res_curse", nil, "material"))

   Assert.eq(enc1, IItemEnchantments.find_enchantment(item, "elona.res_curse", nil, "generated"))
end

function test_IItemEnchantment_enchantment_power()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.res_curse"))

   local enc1 = item:add_enchantment("elona.res_curse", 20, {})
   Assert.eq(20, IItemEnchantments.enchantment_power(item, "elona.res_curse"))

   item:add_enchantment("elona.res_curse", 15, {})
   Assert.eq(35, IItemEnchantments.enchantment_power(item, "elona.res_curse"))

   Assert.is_truthy(item:remove_enchantment(enc1))
   Assert.eq(15, IItemEnchantments.enchantment_power(item, "elona.res_curse"))
end

function test_IItemEnchantment_enchantment_power__merging()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.modify_attribute", {skill_id="elona.stat_strength"}))

   local enc1 = item:add_enchantment("elona.modify_attribute", 20, {skill_id="elona.stat_strength"})
   Assert.eq(20, IItemEnchantments.enchantment_power(item, "elona.modify_attribute", {skill_id="elona.stat_strength"}))

   local enc2 = item:add_enchantment("elona.res_curse", 15, {})
   Assert.eq(20, IItemEnchantments.enchantment_power(item, "elona.modify_attribute", {skill_id="elona.stat_strength"}))
   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.modify_attribute", {skill_id="elona.stat_perception"}))
   Assert.eq(15, IItemEnchantments.enchantment_power(item, "elona.res_curse"))

   local enc3 = item:add_enchantment("elona.modify_attribute", 15, {skill_id="elona.stat_strength"})
   Assert.eq(35, IItemEnchantments.enchantment_power(item, "elona.modify_attribute", {skill_id="elona.stat_strength"}))
   Assert.eq(15, IItemEnchantments.enchantment_power(item, "elona.res_curse"))

   Assert.is_truthy(item:remove_enchantment(enc1))
   Assert.eq(15, IItemEnchantments.enchantment_power(item, "elona.modify_attribute", {skill_id="elona.stat_strength"}))
   Assert.eq(15, IItemEnchantments.enchantment_power(item, "elona.res_curse"))

   Assert.is_truthy(item:remove_enchantment(enc2))
   Assert.eq(15, IItemEnchantments.enchantment_power(item, "elona.modify_attribute", {skill_id="elona.stat_strength"}))
   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.res_curse"))

   Assert.is_truthy(item:remove_enchantment(enc3))
   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.modify_attribute", {skill_id="elona.stat_strength"}))
   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.res_curse"))
end

function test_IItemEnchantment__mod_base_enchantment_power__no_preexisting()
   local item = enchantless_item("elona.long_bow")

   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.res_curse"))
   Assert.eq(0, IItemEnchantments.iter_enchantments(item):length())
   Assert.eq(0, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())

   Assert.eq(true, IItemEnchantments.mod_base_enchantment_power(item, "elona.res_curse", {}, 150))
   Assert.eq(150, IItemEnchantments.enchantment_power(item, "elona.res_curse"))
   Assert.eq(1, IItemEnchantments.iter_enchantments(item):length())
   Assert.eq(1, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())

   Assert.eq(true, IItemEnchantments.mod_base_enchantment_power(item, "elona.res_curse", {}, 200))
   Assert.eq(350, IItemEnchantments.enchantment_power(item, "elona.res_curse"))
   Assert.eq(1, IItemEnchantments.iter_enchantments(item):length())
   Assert.eq(1, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())

   item:remove_enchantment("elona.res_curse")
   Assert.eq(0, IItemEnchantments.enchantment_power(item, "elona.res_curse"))
   Assert.eq(0, IItemEnchantments.iter_enchantments(item):length())
   Assert.eq(0, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())
end

function test_IItemEnchantment__mod_base_enchantment_power__with_preexisting()
   local item = enchantless_item("elona.blood_moon")

   Assert.eq(300, IItemEnchantments.enchantment_power(item, "elona.absorb_mana"))
   Assert.eq(6, IItemEnchantments.iter_enchantments(item):length())
   Assert.eq(6, IItemEnchantments.iter_enchantments(item, nil, nil, "item"):length())
   Assert.eq(0, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())

   Assert.eq(true, IItemEnchantments.mod_base_enchantment_power(item, "elona.absorb_mana", {}, 150))
   Assert.eq(450, IItemEnchantments.enchantment_power(item, "elona.absorb_mana"))
   Assert.eq(7, IItemEnchantments.iter_enchantments(item):length())
   Assert.eq(6, IItemEnchantments.iter_enchantments(item, nil, nil, "item"):length())
   Assert.eq(1, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())

   Assert.eq(true, IItemEnchantments.mod_base_enchantment_power(item, "elona.absorb_mana", {}, 200))
   Assert.eq(650, IItemEnchantments.enchantment_power(item, "elona.absorb_mana"))
   Assert.eq(7, IItemEnchantments.iter_enchantments(item):length())
   Assert.eq(6, IItemEnchantments.iter_enchantments(item, nil, nil, "item"):length())
   Assert.eq(1, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())

   item:remove_enchantment("elona.absorb_mana")
   Assert.eq(300, IItemEnchantments.enchantment_power(item, "elona.absorb_mana"))
   Assert.eq(6, IItemEnchantments.iter_enchantments(item):length())
   Assert.eq(6, IItemEnchantments.iter_enchantments(item, nil, nil, "item"):length())
   Assert.eq(0, IItemEnchantments.iter_enchantments(item, nil, nil, "generated"):length())
end

function test_IItemEnchantment_find_enchantment()
   local item = enchantless_item("elona.long_bow")

   local enc = item:add_enchantment("elona.res_curse", 20, "randomized")
   Assert.eq(enc, IItemEnchantments.find_enchantment(item, "elona.res_curse"))

   Assert.is_truthy(item:remove_enchantment(enc))
   Assert.eq(nil, IItemEnchantments.find_enchantment(item, "elona.res_curse"))
end

function test_IItemEnchantment_find_enchantment__among_multiple()
   local item = enchantless_item("elona.blood_moon")

   local enc_item = IItemEnchantments.find_enchantment(item, "elona.absorb_mana")
   Assert.is_truthy(enc_item)

   local enc_generated = item:add_enchantment("elona.absorb_mana", 20, "randomized")
   Assert.eq(enc_generated, IItemEnchantments.find_enchantment(item, "elona.absorb_mana"))
   Assert.eq(enc_generated, IItemEnchantments.find_enchantment(item, "elona.absorb_mana", nil, "generated"))
   Assert.eq(enc_item, IItemEnchantments.find_enchantment(item, "elona.absorb_mana", nil, "item"))

   Assert.is_truthy(item:remove_enchantment(enc_generated))
   Assert.eq(enc_item, IItemEnchantments.find_enchantment(item, "elona.absorb_mana"))
   Assert.eq(nil, IItemEnchantments.find_enchantment(item, "elona.absorb_mana", nil, "generated"))
   Assert.eq(enc_item, IItemEnchantments.find_enchantment(item, "elona.absorb_mana", nil, "item"))
end

function test_IItemEnchantment_calc_total_enchantment_powers()
   local item = enchantless_item("elona.long_bow")

   item:add_enchantment("elona.absorb_mana", 20, "randomized")
   item:add_enchantment("elona.absorb_mana", 50, "randomized")
   item:add_enchantment("elona.absorb_mana", 10, "randomized")

   item:add_enchantment("elona.modify_skill", 20, {skill_id="elona.weight_lifting"})
   item:add_enchantment("elona.modify_skill", 15, {skill_id="elona.weight_lifting"})

   item:add_enchantment("elona.modify_skill", 10, {skill_id="elona.sense_quality"})

   local result = IItemEnchantments.calc_total_enchantment_powers(item:iter_enchantments())

   -- TODO order
   local is_found = function(_id, power, params)
      local filter = function(r) return r._id == _id and r.total_power == power and table.deepcompare(r.params, params) end
      return fun.iter(result):filter(filter):length() == 1
   end
   Assert.eq(true, is_found("elona.absorb_mana", 80, {}))
   Assert.eq(true, is_found("elona.modify_skill", 35, {skill_id="elona.weight_lifting"}))
   Assert.eq(true, is_found("elona.modify_skill", 10, {skill_id="elona.sense_quality"}))
end
