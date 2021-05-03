local TestUtil = require("api.test.TestUtil")
local Assert = require("api.test.Assert")

function test_race_intrinsic_traits()
   local chara = TestUtil.stripped_chara("elona.mutant")

   Assert.eq(1, chara:trait_level("elona.perm_chaos_shape"))
end
