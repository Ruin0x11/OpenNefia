local Chara = require("api.Chara")
local Assert = require("api.test.Assert")

function test_ICharaSkills_init__prototype_defaults()
   local chara = Chara.create("elona.zeome", nil, nil, {ownerless=true})

   Assert.eq(true, chara:has_skill("elona.spell_cure_of_jure"))
   Assert.eq(1, chara:skill_level("elona.spell_cure_of_jure"))
end
