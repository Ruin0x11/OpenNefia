local Assert = require("api.test.Assert")
local test_util = require("test.lib.test_util")

function test_ICharaSkills_init__prototype_default_resistances()
   local chara = test_util.stripped_chara("elona.red_putit")

   Assert.eq(500, chara:resist_level("elona.acid"))
   Assert.eq(112, chara:resist_level("elona.lightning"))

   chara = test_util.stripped_chara("elona.wisp")

   Assert.eq(0, chara:resist_level("elona.acid"))
   Assert.eq(652, chara:resist_level("elona.lightning"))
end

function test_ICharaSkills_init__race_intrinsic_resistances()
   local chara = test_util.stripped_chara("elona.stalker")

   Assert.eq(644, chara:resist_level("elona.darkness"))
   Assert.eq(100, chara:resist_level("elona.magic"))

   chara = test_util.stripped_chara("elona.quickling")

   Assert.eq(136, chara:resist_level("elona.darkness"))
   Assert.eq(636, chara:resist_level("elona.magic"))
end

function test_ICharaSkills_resist_grade()
   local chara = test_util.stripped_chara("elona.putit")

   Assert.eq(2, chara:resist_grade("elona.fire"))

   chara:mod_resist_level("elona.fire", 20, "add")
   Assert.eq(2, chara:resist_grade("elona.fire"))

   chara:mod_resist_level("elona.fire", 30, "add")
   Assert.eq(3, chara:resist_grade("elona.fire"))

   chara:refresh()
   Assert.eq(2, chara:resist_grade("elona.fire"))
end

function test_ICharaSkills_base_resist_grade()
   local chara = test_util.stripped_chara("elona.putit")

   Assert.eq(2, chara:base_resist_grade("elona.fire"))

   chara:mod_base_resist_level("elona.fire", 100, "add")
   Assert.eq(4, chara:base_resist_grade("elona.fire"))

   chara:mod_base_resist_level("elona.fire", 400, "set")
   Assert.eq(8, chara:base_resist_grade("elona.fire"))

   chara:refresh()
   Assert.eq(8, chara:base_resist_grade("elona.fire"))
end

function test_ICharaSkills_mod_resist_level()
   local chara = test_util.stripped_chara("elona.putit")

   Assert.eq(100, chara:resist_level("elona.fire"))

   chara:mod_resist_level("elona.fire", 100, "add")
   Assert.eq(200, chara:resist_level("elona.fire"))

   chara:mod_resist_level("elona.fire", 300, "set")
   Assert.eq(300, chara:resist_level("elona.fire"))

   chara:refresh()
   Assert.eq(100, chara:resist_level("elona.fire"))
end

function test_ICharaSkills_mod_base_resist_level()
   local chara = test_util.stripped_chara("elona.putit")

   Assert.eq(100, chara:resist_level("elona.fire"))

   chara:mod_base_resist_level("elona.fire", 100, "add")
   Assert.eq(200, chara:resist_level("elona.fire"))

   chara:mod_base_resist_level("elona.fire", 300, "set")
   Assert.eq(300, chara:resist_level("elona.fire"))

   chara:refresh()
   Assert.eq(300, chara:resist_level("elona.fire"))
end
