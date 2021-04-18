local ElonaAction = require("mod.elona.api.ElonaAction")
local TestUtil = require("api.test.TestUtil")
local Assert = require("api.test.Assert")

function test_ElonaAction_get_melee_weapons()
   local chara = TestUtil.stripped_chara("elona.wizard_of_elea")

   Assert.eq(0, ElonaAction.get_melee_weapons(chara):length())

   local dagger = TestUtil.stripped_item("elona.dagger", chara)
   local sword = TestUtil.stripped_item("elona.long_sword", chara)
   local boots = TestUtil.stripped_item("elona.composite_boots", chara)
   local bow = TestUtil.stripped_item("elona.long_bow", chara)

   Assert.is_truthy(chara:equip_item(dagger))
   Assert.eq(1, ElonaAction.get_melee_weapons(chara):length())

   Assert.is_truthy(chara:equip_item(sword))
   Assert.is_truthy(chara:equip_item(boots))
   Assert.is_truthy(chara:equip_item(bow))
   Assert.eq(2, ElonaAction.get_melee_weapons(chara):length())

   Assert.is_truthy(chara:unequip_item(dagger))
   Assert.is_truthy(chara:unequip_item(sword))
   Assert.is_truthy(chara:unequip_item(boots))
   Assert.is_truthy(chara:unequip_item(bow))
   Assert.eq(0, ElonaAction.get_melee_weapons(chara):length())
end
