function test_ElonaAction_get_melee_weapons()
   local chara = TestUtil.stripped_chara("elona.wizard_of_elea")

   local dagger = TestUtil.stripped_item("elona.dagger", chara)
   local sword = TestUtil.stripped_item("elona.long_sword", chara)
   local boots = TestUtil.stripped_item("elona.composite_boots", chara)
   local bow = TestUtil.stripped_item("elona.long_bow", chara)

   Assert.is_truthy(chara:equip_item(dagger))
   Assert.is_truthy(chara:equip_item(sword))
   Assert.is_truthy(chara:equip_item(boots))
   Assert.is_truthy(chara:equip_item(bow))
end
