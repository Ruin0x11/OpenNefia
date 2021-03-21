local Calc = require("mod.elona.api.Calc")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Charagen = require("mod.elona.api.Charagen")
local Chara = require("api.Chara")
local Log = require("api.Log")

local ElonaChara = {}

function ElonaChara.default_filter(map)
   -- >>>>>>>> shade2/map.hsp:100 	flt calcObjLv(cLevel(pc)),calcFixLv(fixNormal) ...
   return {
      level = Calc.calc_object_level(Chara.player():calc("level"), map),
      quality = Calc.calc_object_quality(Enum.Quality.Normal)
   }
   -- <<<<<<<< shade2/map.hsp:100 	flt calcObjLv(cLevel(pc)),calcFixLv(fixNormal) ..
end

function ElonaChara.random_filter(map)
   local archetype = map:archetype()
   if archetype and archetype.chara_filter then
      return archetype.chara_filter
   end

   return ElonaChara.default_filter
end

function ElonaChara.spawn_mobs(map, chara_id)
-- >>>>>>>> shade2/map.hsp:104 *chara_spawn ...
   map = map or Map.current()

   local chara_filter = ElonaChara.random_filter(map)

   map:emit("elona.before_spawn_mobs", {chara_filter=chara_filter, chara_id=chara_id})

   -- >>>>>>>> shade2/map.hsp:108  ..
   local density = map:calc("max_crowd_density")

   if density <= 0 then
      return
   end

   if map.crowd_density < density / 4 and Rand.one_in(2) then
      local filter = chara_filter(map)
      filter.id = filter.id or chara_id
      Charagen.create(nil, nil, filter, map)
   end
   if map.crowd_density < density / 2 and Rand.one_in(4) then
      local filter = chara_filter(map)
      filter.id = filter.id or chara_id
      Charagen.create(nil, nil, filter, map)
   end
   if map.crowd_density < density and Rand.one_in(8) then
      local filter = chara_filter(map)
      filter.id = filter.id or chara_id
      Charagen.create(nil, nil, filter, map)
   end
   -- <<<<<<<< shade2/map.hsp:113 	return ..
end

local HUMAN_IMAGES = {
   male = {
      "elona.chara_human_male",
      "elona.chara_elea_male",
      "elona.chara_eulderna_male",
      "elona.chara_trainer_male",
      "elona.chara_juere_male",
      "elona.chara_adventurer_male_1",
      "elona.chara_wizard_male",
      "elona.chara_informer_male",
      "elona.chara_adventurer_male_2",
      "elona.chara_adventurer_male_3",
      "elona.chara_warrior_male",
      "elona.chara_moyer_the_crooked",
      "elona.chara_guard",
      "elona.chara_punk_female",
      "elona.chara_adventurer_male_4",
      "elona.chara_gangster_male",
      "elona.chara_adventurer_male_5",
      "elona.chara_adventurer_male_6",
      "elona.chara_fallen_soldier",
      "elona.chara_adventurer_male_7",
      "elona.chara_arena_master",
      "elona.chara_adventurer_male_8",
      "elona.chara_adventurer_male_9",
      "elona.chara_wizard_of_elea_male",
      "elona.chara_adventurer_male_10",
      "elona.chara_adventurer_male_11",
      "elona.chara_adventurer_male_12",
      "elona.chara_adventurer_male_13",
      "elona.chara_mercenary_archer",
      "elona.chara_adventurer_male_14",
      "elona.chara_adventurer_male_15",
      "elona.chara_adventurer_male_16",
      "elona.chara_adventurer_male_17",
   },
   female = {
      "elona.chara_human_female",
      "elona.chara_elea_female",
      "elona.chara_eulderna_female",
      "elona.chara_miches",
      "elona.chara_juere_female",
      "elona.chara_adventurer_female_1",
      "elona.chara_wizard_female",
      "elona.chara_informer_female",
      "elona.chara_adventurer_female_2",
      "elona.chara_warrior_female",
      "elona.chara_adventurer_female_3",
      "elona.chara_adventurer_female_4",
      "elona.chara_adventurer_female_5",
      "elona.chara_adventurer_female_6",
      "elona.chara_adventurer_female_7",
      "elona.chara_adventurer_female_8",
      "elona.chara_warrior_of_elea_female",
      "elona.chara_gangster_female",
      "elona.chara_adventurer_female_9",
      "elona.chara_adventurer_female_10",
      "elona.chara_wizard_of_elea_female",
      "elona.chara_adventurer_female_11",
      "elona.chara_adventurer_female_12",
      "elona.chara_adventurer_female_13",
      "elona.chara_adventurer_female_14",
      "elona.chara_adventurer_female_15",
      "elona.chara_adventurer_female_16",
      "elona.chara_adventurer_female_17",
      "elona.chara_adventurer_female_18",
      "elona.chara_adventurer_female_19",
      "elona.chara_adventurer_female_20",
      "elona.chara_adventurer_female_21",
   }
}

function ElonaChara.random_human_image(adv)
   local gender = adv.gender or "female"
   return Rand.choice(HUMAN_IMAGES[gender])
end

return ElonaChara
