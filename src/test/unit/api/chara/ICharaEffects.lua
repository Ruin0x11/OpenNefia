local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local Enum = require("api.Enum")
local IOwned = require("api.IOwned")
local Rand = require("api.Rand")

local function stripped_chara(id)
   local chara = Chara.create(id, nil, nil, {ownerless=true})
   chara:iter_items():each(IOwned.remove_ownership)
   return chara
end

function test_ICharaEffects_apply_effect__adjusted_power()
   local chara = stripped_chara("elona.putit")

   chara:apply_effect("elona.bleeding", 100)
   Assert.eq(4, chara:effect_turns("elona.bleeding"))

   chara:remove_effect("elona.bleeding")
   chara.quality = Enum.Quality.Great
   chara:apply_effect("elona.bleeding", 100)
   Assert.eq(2, chara:effect_turns("elona.bleeding"))
end

function test_ICharaEffects_apply_effect__elemental_resist()
   local chara = stripped_chara("elona.putit")

   Rand.set_seed(0) -- elemental resist is based on random chance
   chara:mod_resist_level("elona.sound", 0, "set")
   chara:apply_effect("elona.dimming", 100)
   Assert.eq(22, chara:effect_turns("elona.dimming"))

   chara:refresh()
   Rand.set_seed(0) -- elemental resist is based on random chance
   chara:remove_effect("elona.dimming")
   chara:mod_resist_level("elona.sound", 50 * 6, "set")
   chara:apply_effect("elona.dimming", 100)
   Assert.eq(0, chara:effect_turns("elona.dimming"))
end

function test_ICharaEffects_apply_effect__racial_immunity()
   local chara = stripped_chara("elona.steel_golem")

   Assert.eq(true, chara:is_immune_to_effect("elona.dimming"))

   chara:apply_effect("elona.dimming", 1000)
   Assert.eq(false, chara:has_effect("elona.dimming"))
   Assert.eq(0, chara:effect_turns("elona.dimming"))
end

function test_ICharaEffects_apply_effect__prototype_immunity()
   local chara = stripped_chara("elona.mine_dog")

   Assert.eq(true, chara:is_immune_to_effect("elona.fear"))

   chara:apply_effect("elona.fear", 1000)
   Assert.eq(false, chara:has_effect("elona.fear"))
   Assert.eq(0, chara:effect_turns("elona.fear"))
end

function test_ICharaEffects_apply_effect__quality_resist()
   local chara = stripped_chara("elona.putit")

   Rand.set_seed(0)
   chara.level = 1
   chara.quality = Enum.Quality.Bad
   chara:apply_effect("elona.paralysis", 1000)
   Assert.eq(59, chara:effect_turns("elona.paralysis"))

   Rand.set_seed(0)
   chara:remove_effect("elona.paralysis")
   chara.level = 100
   chara.quality = Enum.Quality.Great
   chara:apply_effect("elona.paralysis", 1000)
   Assert.eq(0, chara:effect_turns("elona.paralysis"))
end
