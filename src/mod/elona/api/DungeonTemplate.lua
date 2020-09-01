local Dungeon = require("mod.elona.api.Dungeon")
local Rand = require("api.Rand")
local Itemgen = require("mod.tools.api.Itemgen")
local Filters = require("mod.elona.api.Filters")

local DungeonTemplate = {}

function DungeonTemplate.type_1(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   return Dungeon.gen_type_1, params
end

function DungeonTemplate.type_2(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.has_monster_houses = true
   return Dungeon.gen_type_2, params
end

function DungeonTemplate.type_3(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.calc_density = function(map)
      local crowd_density = map:calc("max_crowd_density")
      return {
         mob = crowd_density / 2,
         item = crowd_density / 3
      }
   end

   return Dungeon.gen_type_3, params
end

function DungeonTemplate.type_4(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   return Dungeon.gen_type_4, params
end

function DungeonTemplate.type_5(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   return Dungeon.gen_type_5, params
end

function DungeonTemplate.type_6(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   return Dungeon.gen_type_6, params
end

function DungeonTemplate.type_8(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.calc_density = function(map)
      local crowd_density = map:calc("max_crowd_density")
      return {
         mob = crowd_density / 4,
         item = crowd_density / 10
      }
   end

   return Dungeon.gen_type_8, params
end

function DungeonTemplate.type_9(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.calc_density = function(map)
      local crowd_density = map:calc("max_crowd_density")
      return {
         mob = crowd_density / 3,
         item = crowd_density / 10
      }
   end
   params.after_generate = function(map)
      Itemgen.create(nil, nil, {categories=Rand.choice(Filters.fsetwear), quality=6}, map)
   end

   return Dungeon.gen_type_9, params
end

function DungeonTemplate.type_10(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   function params.calc_density(map)
      local crowd_density = map:calc("max_crowd_density")
      return {
         mob = crowd_density / 3,
         item = crowd_density / 6
      }
   end

   return Dungeon.gen_type_10, params
end


function DungeonTemplate.nefia_dungeon(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.tileset = "elona.dungeon"

   local gen = DungeonTemplate.type_2
   if Rand.one_in(4) then
      gen = DungeonTemplate.type_1
   end
   if Rand.one_in(6) then
      gen = DungeonTemplate.type_10
   end
   if Rand.one_in(10) then
      gen = DungeonTemplate.type_4
   end
   if Rand.one_in(25) then
      gen = DungeonTemplate.type_8
   end
   if Rand.one_in(25) then
      params.tileset = "elona.water"
   end

   return gen(area, floor, params)
end
-- image = "elona.feat_area_cave",

function DungeonTemplate.nefia_tower(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.tileset = "elona.tower_1"

   local gen = DungeonTemplate.type_1
   if Rand.one_in(5) then
      gen = DungeonTemplate.type_4
   end
   if Rand.one_in(10) then
      gen = DungeonTemplate.type_3
   end
   if Rand.one_in(25) then
      gen = DungeonTemplate.type_2
   end
   if Rand.one_in(40) then
      params.tileset = "elona.water"
   end

   return gen(area, floor, params)
end
-- image = "elona.feat_area_tower",

function DungeonTemplate.nefia_forest(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.tileset = "elona.dungeon_forest"

   local gen = DungeonTemplate.type_2
   if Rand.one_in(6) then
      gen = DungeonTemplate.type_1
   end
   if Rand.one_in(6) then
      gen = DungeonTemplate.type_10
   end
   if Rand.one_in(25) then
      gen = DungeonTemplate.type_8
   end
   if Rand.one_in(20) then
      gen = DungeonTemplate.type_4
   end

   return gen(area, floor, params)
end
-- image = "elona.feat_area_tree",

function DungeonTemplate.nefia_castle(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.tileset = "elona.dungeon_castle"

   local gen = DungeonTemplate.type_1
   if Rand.one_in(5) then
      gen = DungeonTemplate.type_4
   end
   if Rand.one_in(6) then
      gen = DungeonTemplate.type_5
   end
   if Rand.one_in(7) then
      gen = DungeonTemplate.type_2
   end
   if Rand.one_in(40) then
      params.tileset = "elona.water"
   end

   return gen(area, floor, params)
end
-- image = "elona.feat_area_temple",

local function scale_density_with_floor(gen_params)
   gen_params.max_crowd_density = gen_params.width * gen_params.height / 100 + gen_params.level / 2
   return gen_params
end

function DungeonTemplate.lesimas(area, floor, params)
   params.level = (params.level or 1) + floor - 1
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

   local gen = DungeonTemplate.type_1
   if Rand.one_in(30) then
      gen = DungeonTemplate.type_3
   end

   local levels = {
      [1] = DungeonTemplate.type_2,
      [5] = DungeonTemplate.type_5,
      [10] = DungeonTemplate.type_3,
      [15] = DungeonTemplate.type_5,
      [20] = DungeonTemplate.type_3,
      [25] = DungeonTemplate.type_5,
      [30] = DungeonTemplate.type_3,
   }

   if levels[floor] then
      gen = levels[floor]
   else
      if floor < 30 and Rand.one_in(4) then
         gen = DungeonTemplate.type_2
      end

      if Rand.one_in(5) then
         gen = DungeonTemplate.type_4
      end
      if Rand.one_in(20) then
         gen = DungeonTemplate.type_8
      end
      if Rand.one_in(6) then
         gen = DungeonTemplate.type_10
      end
   end

   return gen(area, floor, params)
end
-- image = "elona.feat_area_cave",

function DungeonTemplate.tower_of_fire(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.tileset = "elona.tower_of_fire"
   params.on_generate_params = scale_density_with_floor

   return Dungeon.gen_type_1, params
end

function DungeonTemplate.crypt_of_the_damned(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.tileset = "elona.dungeon"
   params.on_generate_params = scale_density_with_floor

   return Dungeon.gen_type_1, params
end

function DungeonTemplate.ancient_castle(area, floor, params)
   params.level = (params.level or 1) + floor - 1
   params.tileset = "elona.dungeon_castle"
   params.on_generate_params = scale_density_with_floor

   return Dungeon.gen_type_1, params
end

return DungeonTemplate
