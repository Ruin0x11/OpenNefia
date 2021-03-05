local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local IOwned = require("api.IOwned")

local function stripped_chara(id)
   local chara = Chara.create(id, nil, nil, {ownerless=true})
   chara:iter_items():each(IOwned.remove_ownership)
   return chara
end

function test_ICharaSkills_init__prototype_default_skills()
   local chara = stripped_chara("elona.zeome")

   Assert.eq(true, chara:has_skill("elona.spell_cure_of_jure"))
   Assert.eq(1, chara:skill_level("elona.spell_cure_of_jure"))
end
