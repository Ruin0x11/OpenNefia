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

function test_ICharaSkills_init__initial_skills()
   local chara = stripped_chara("elona.putit")

   Assert.eq(true, chara:has_skill("elona.axe"))
   Assert.eq(true, chara:has_skill("elona.blunt"))
   Assert.eq(true, chara:has_skill("elona.bow"))
   Assert.eq(true, chara:has_skill("elona.crossbow"))
   Assert.eq(true, chara:has_skill("elona.evasion"))
   Assert.eq(true, chara:has_skill("elona.faith"))
   Assert.eq(true, chara:has_skill("elona.healing"))
   Assert.eq(true, chara:has_skill("elona.heavy_armor"))
   Assert.eq(true, chara:has_skill("elona.light_armor"))
   Assert.eq(true, chara:has_skill("elona.long_sword"))
   Assert.eq(true, chara:has_skill("elona.martial_arts"))
   Assert.eq(true, chara:has_skill("elona.meditation"))
   Assert.eq(true, chara:has_skill("elona.medium_armor"))
   Assert.eq(true, chara:has_skill("elona.polearm"))
   Assert.eq(true, chara:has_skill("elona.scythe"))
   Assert.eq(true, chara:has_skill("elona.shield"))
   Assert.eq(true, chara:has_skill("elona.short_sword"))
   Assert.eq(true, chara:has_skill("elona.stat_luck"))
   Assert.eq(true, chara:has_skill("elona.stave"))
   Assert.eq(true, chara:has_skill("elona.stealth"))
   Assert.eq(true, chara:has_skill("elona.throwing"))
end
