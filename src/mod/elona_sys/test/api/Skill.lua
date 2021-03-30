local Skill = require("mod.elona_sys.api.Skill")
local Assert = require("api.test.Assert")
local test_util = require("api.test.test_util")

function test_Skill_modify_resist_level()
   local chara = test_util.stripped_chara("elona.putit")

   chara:mod_base_resist_level("elona.fire", 100, "set")
   Assert.eq(100, chara:base_resist_level("elona.fire"))
   Assert.eq(100, chara:resist_level("elona.fire"))

   Skill.modify_resist_level(chara, "elona.fire", 200)

   Assert.eq(200, chara:base_resist_level("elona.fire"))
   Assert.eq(200, chara:resist_level("elona.fire"))
end
