local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Charagen = require("mod.elona.api.Charagen")
local Text = require("mod.elona.api.Text")
local Area = require("api.Area")
local Home = require("mod.elona.api.Home")
local Log = require("api.Log")
local Map = require("api.Map")

local Adventurer = {}

-- >>>>>>>> shade2/init.hsp:85 	#define global maxAdv		40-maxNullChara ...
Adventurer.MAX_ADVENTURERS = 40 - 1
-- <<<<<<<< shade2/init.hsp:85 	#define global maxAdv		40-maxNullChara ..

local is_adventurer = function(chara) return chara:find_role("elona.adventurer") end

function Adventurer.iter(map)
   local staying = save.elona.staying_adventurers:iter()
   local in_map = Chara.iter(map or Map.current())
   return fun.chain(staying, in_map):filter(is_adventurer)
end

function Adventurer.iter_in_map(map)
   return Chara.iter(map):filter(is_adventurer)
end

function Adventurer.initialize()
   -- >>>>>>>> shade2/adv.hsp:21 *adv_init ...
   for _ = 1, Adventurer.MAX_ADVENTURERS do
      Adventurer.generate_and_place()
   end
   -- <<<<<<<< shade2/adv.hsp:26 	return ..
end

local ADVENTURER_IDS = {
   "elona.warrior",
   "elona.wizard",
   "elona.mercenary_archer"
}

function Adventurer.random_adventurer_id(player)
   return Rand.choice(ADVENTURER_IDS)
end

local ADVENTURER_IMAGES = {
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

function Adventurer.random_adventurer_image(adv)
   local gender = adv.gender or "female"
   return Rand.choice(ADVENTURER_IMAGES[gender])
end

function Adventurer.calc_adventurer_level(player)
   player = player or Chara.player()
   -- >>>>>>>> shade2/adv.hsp:30 	flt 0,fixGreat: initLv=rnd(60+cLevel(pc))+1 ...
   return Rand.rnd(60 + player.level) + 1
   -- <<<<<<<< shade2/adv.hsp:30 	flt 0,fixGreat: initLv=rnd(60+cLevel(pc))+1 ..
end

function Adventurer.calc_starting_area(adv)
   -- >>>>>>>> shade2/adv.hsp:40 	p=rnd(headRandArea) ...
   local area = Rand.choice(Area.iter())
   -- TODO maybe we need a way to tag an area with a map type, to prevent
   -- adventurers from spawning in weird places.
   --

   local archetype = area:archetype()
   if archetype == nil
      or archetype.on_generate_floor == nil
      or Home.is_home_area(area)
   then
      area = Area.create_unique("elona.north_tyris")
   end
   if Rand.one_in(4) then
      area = Area.create_unique("elona.vernis")
   end
   if Rand.one_in(4) then
      area = Area.create_unique("elona.vernis")
   end
   if Rand.one_in(6) then
      area = Area.create_unique("elona.yowyn")
   end
   return area
   -- <<<<<<<< shade2/adv.hsp:44 	if rnd(6)=0:p=areaYowyn ..
end

function Adventurer.calc_starting_fame(adv)
   return (adv.level ^ 2) * 30 + Rand.rnd(adv.level * 200 + 100) + Rand.rnd(500)
end

function Adventurer.generate()
   -- >>>>>>>> shade2/adv.hsp:29 *adv_generate ...
   local filter = {
      level = 0,
      quality = Enum.Quality.Great,
      initial_level = Adventurer.calc_adventurer_level(),
      id = Adventurer.random_adventurer_id(),
      ownerless = true
   }
   local adv = Charagen.create(nil, nil, filter)
   adv.relation = Enum.Relation.Neutral
   adv.image = Adventurer.random_adventurer_image(adv)
   adv.name = Text.random_name()
   adv.title = Text.random_title()
   adv:add_role("elona.adventurer", { state = "Alive" })
   adv.fame = Adventurer.calc_starting_fame(adv)

   return adv
   -- <<<<<<<< shade2/adv.hsp:47 	return ..
end

function Adventurer.generate_and_place()
   local adv = Adventurer.generate()

   local area = Adventurer.calc_starting_area()

   if not save.elona.staying_adventurers:take_object(adv) then
      Log.error("Could not place adventurer in staying adventurers pool.")
      return nil
   end
   save.elona.staying_adventurers:register(adv, area)

   return adv
end

return Adventurer
