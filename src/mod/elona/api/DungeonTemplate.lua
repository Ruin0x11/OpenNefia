local Dungeon = require("mod.elona.api.Dungeon")
local Rand = require("api.Rand")
local Itemgen = require("mod.tools.api.Itemgen")
local Filters = require("mod.elona.api.Filters")
local Nefia = require("mod.elona.api.Nefia")

-- Dungeon templates are composable.
--
-- Each function here returns a generator function and a list of parameters to
-- be passed to DungeonMap.generate(). The key thing is that calls to each
-- generator can be nested. You can pick a generator per floor level or
-- randomly, and have special random generation logic for each floor. This is
-- used to great effect, even for complex dungeons like Lesimas with a lot of
-- special behavior.
local DungeonTemplate = {}

function DungeonTemplate.type_standard(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   return Dungeon.gen_type_standard, params
end

function DungeonTemplate.type_wide(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.has_monster_houses = true
   return Dungeon.gen_type_wide, params
end

function DungeonTemplate.type_big_room(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)

   -- >>>>>>>> shade2/map_rand.hsp:227 	if rdType=rdBigRoom{	 ...
   params.calc_density = function(map)
      local crowd_density = map:calc("max_crowd_density")
      return {
         mob = crowd_density / 2,
         item = crowd_density / 3
      }
   end
   -- <<<<<<<< shade2/map_rand.hsp:231 		} ..

   return Dungeon.gen_type_big_room, params
end

function DungeonTemplate.type_resident(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   return Dungeon.gen_type_resident, params
end

function DungeonTemplate.type_jail(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   return Dungeon.gen_type_jail, params
end

function DungeonTemplate.type_hunt(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   return Dungeon.gen_type_hunt, params
end

function DungeonTemplate.type_long(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)

   -- >>>>>>>> shade2/map_rand.hsp:233 	if rdType=rdLong{	 ...
   params.calc_density = function(map)
      local crowd_density = map:calc("max_crowd_density")
      return {
         mob = crowd_density / 4,
         item = crowd_density / 10
      }
   end
   -- <<<<<<<< shade2/map_rand.hsp:236 		} ..

   return Dungeon.gen_type_long, params
end

function DungeonTemplate.type_maze(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)

   -- >>>>>>>> shade2/map_rand.hsp:243 	if rdType=rdMaze{	 ...
   params.calc_density = function(map)
      local crowd_density = map:calc("max_crowd_density")
      return {
         mob = crowd_density / 3,
         item = crowd_density / 10
      }
   end
   -- <<<<<<<< shade2/map_rand.hsp:246 		} ..

   params.after_generate = function(map)
      Itemgen.create(nil, nil, {categories=Rand.choice(Filters.fsetwear), quality=6}, map)
   end

   return Dungeon.gen_type_maze, params
end

function DungeonTemplate.type_puppy_cave(floor, params)
   params.level = Nefia.calc_nefia_map_level(floor, params.level)

   -- >>>>>>>> shade2/map_rand.hsp:238 	if rdType=rdDog{	 ...
   function params.calc_density(map)
      local crowd_density = map:calc("max_crowd_density")
      return {
         mob = crowd_density / 3,
         item = crowd_density / 6
      }
   end
   -- <<<<<<<< shade2/map_rand.hsp:241 		} ..

   return Dungeon.gen_type_puppy_cave, params
end


function DungeonTemplate.nefia_dungeon(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:27 	if areaType(gArea)=mTypeDungeon{ ...
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.dungeon"
   -- >>>>>>>> shade2/proc.hsp:18 	if mType=mTypeDungeon	: atxSpot=atxDungeon1 ...
   Dungeon.set_template_property(params, "material_spot", "elona.dungeon")
   -- <<<<<<<< shade2/proc.hsp:18 	if mType=mTypeDungeon	: atxSpot=atxDungeon1 ...

   local gen = DungeonTemplate.type_wide
   if Rand.one_in(4) then
      gen = DungeonTemplate.type_standard
   end
   if Rand.one_in(6) then
      gen = DungeonTemplate.type_puppy_cave
   end
   if Rand.one_in(10) then
      gen = DungeonTemplate.type_resident
   end
   if Rand.one_in(25) then
      gen = DungeonTemplate.type_long
   end
   if Rand.one_in(20) then
      params.tileset = "elona.water"
   end

   return gen(floor, params)
   -- <<<<<<<< shade2/map_rand.hsp:34 		} ..
end
-- image = "elona.feat_area_cave",

function DungeonTemplate.nefia_forest(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:36 	if areaType(gArea)=mTypeForest{ ...
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.dungeon_forest"
   -- >>>>>>>> shade2/proc.hsp:20 	if mType=mTypeForest	: atxSpot=atxForest1 ...
   Dungeon.set_template_property(params, "material_spot", "elona.forest")
   -- <<<<<<<< shade2/proc.hsp:20 	if mType=mTypeForest	: atxSpot=atxForest1 ..

   local gen = DungeonTemplate.type_wide
   if Rand.one_in(6) then
      gen = DungeonTemplate.type_standard
   end
   if Rand.one_in(6) then
      gen = DungeonTemplate.type_puppy_cave
   end
   if Rand.one_in(25) then
      gen = DungeonTemplate.type_long
   end
   if Rand.one_in(20) then
      gen = DungeonTemplate.type_resident
   end

   return gen(floor, params)
   -- <<<<<<<< shade2/map_rand.hsp:42 		} ..
end
-- image = "elona.feat_area_tree",

function DungeonTemplate.nefia_tower(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:44 	if areaType(gArea)=mTypeTower{ ...
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.tower_1"
   -- >>>>>>>> shade2/proc.hsp:19 	if mType=mTypeTower	: atxSpot=atxBuilding1 ...
   Dungeon.set_template_property(params, "material_spot", "elona.building")
   -- <<<<<<<< shade2/proc.hsp:19 	if mType=mTypeTower	: atxSpot=atxBuilding1 ..

   local gen = DungeonTemplate.type_standard
   if Rand.one_in(5) then
      gen = DungeonTemplate.type_resident
   end
   if Rand.one_in(10) then
      gen = DungeonTemplate.type_big_room
   end
   if Rand.one_in(25) then
      gen = DungeonTemplate.type_wide
   end
   if Rand.one_in(40) then
      params.tileset = "elona.water"
   end

   return gen(floor, params)
   -- <<<<<<<< shade2/map_rand.hsp:50 		} ..
end
-- image = "elona.feat_area_tower",

function DungeonTemplate.nefia_fort(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:52 	if areaType(gArea)=mTypeFort{ ...
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.dungeon_castle"
   -- >>>>>>>> shade2/proc.hsp:21 	if mType=mTypeFort	: atxSpot=atxBuilding1	 ...
   Dungeon.set_template_property(params, "material_spot", "elona.building")
   -- <<<<<<<< shade2/proc.hsp:21 	if mType=mTypeFort	: atxSpot=atxBuilding1	 ..

   local gen = DungeonTemplate.type_standard
   if Rand.one_in(5) then
      gen = DungeonTemplate.type_resident
   end
   if Rand.one_in(6) then
      gen = DungeonTemplate.type_jail
   end
   if Rand.one_in(7) then
      gen = DungeonTemplate.type_wide
   end
   if Rand.one_in(40) then
      params.tileset = "elona.water"
   end

   return gen(floor, params)
   -- <<<<<<<< shade2/map_rand.hsp:58 		} ..
end
-- image = "elona.feat_area_temple",

local function scale_density_with_floor(gen_params)
   -- >>>>>>>> shade2/map_rand.hsp:61 		mModerateCrowd+=gLevel/2 ...
   gen_params.max_crowd_density = gen_params.width * gen_params.height / 100 + gen_params.level / 2
   return gen_params
   -- <<<<<<<< shade2/map_rand.hsp:61 		mModerateCrowd+=gLevel/2 ..
end

function DungeonTemplate.lesimas(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:60 	if areaId(gArea)=areaLesimas{ ...
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.lesimas"
   params.on_generate_params = scale_density_with_floor

   if Rand.one_in(20) then
      params.tileset = "elona.water"
   end
   if floor < 35 then
      params.tileset = "elona.dungeon"
   end
   if floor < 20 then
      params.tileset = "elona.tower_1"
   end
   if floor < 10 then
      params.tileset = "elona.tower_2"
   end
   if floor < 5 then
      params.tileset = "elona.dungeon"
   end

   local gen = DungeonTemplate.type_standard
   if Rand.one_in(30) then
      gen = DungeonTemplate.type_big_room
   end

   local levels = {
      [1] = DungeonTemplate.type_wide,
      [5] = DungeonTemplate.type_jail,
      [10] = DungeonTemplate.type_big_room,
      [15] = DungeonTemplate.type_jail,
      [20] = DungeonTemplate.type_big_room,
      [25] = DungeonTemplate.type_jail,
      [30] = DungeonTemplate.type_big_room,
   }

   if levels[floor] then
      gen = levels[floor]
   else
      if floor < 30 and Rand.one_in(4) then
         gen = DungeonTemplate.type_wide
      end

      if Rand.one_in(5) then
         gen = DungeonTemplate.type_resident
      end
      if Rand.one_in(20) then
         gen = DungeonTemplate.type_long
      end
      if Rand.one_in(6) then
         gen = DungeonTemplate.type_puppy_cave
      end
   end

   return gen(floor, params)
   -- <<<<<<<< shade2/map_rand.hsp:86 		} ..
end
-- image = "elona.feat_area_cave",

function DungeonTemplate.tower_of_fire(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:88 	if areaId(gArea)=areaFireTrial{ ...
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.tower_of_fire"
   params.on_generate_params = scale_density_with_floor

   return Dungeon.gen_type_standard, params
   -- <<<<<<<< shade2/map_rand.hsp:92 		} ..
end

function DungeonTemplate.crypt_of_the_damned(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:93 	if areaId(gArea)=areaUndeadTrial{ ...
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.dungeon"
   params.on_generate_params = scale_density_with_floor

   return Dungeon.gen_type_standard, params
   -- <<<<<<<< shade2/map_rand.hsp:97 		} ..
end

function DungeonTemplate.ancient_castle(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:98 	if areaId(gArea)=areaRogueTrial{ ...
   params.level = Nefia.calc_nefia_map_level(floor, params.level)
   params.tileset = "elona.dungeon_castle"
   params.on_generate_params = scale_density_with_floor

   return Dungeon.gen_type_standard, params
   -- <<<<<<<< shade2/map_rand.hsp:102 		} ..
end

return DungeonTemplate
