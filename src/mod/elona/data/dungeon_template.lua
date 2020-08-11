local DungeonMap = require("mod.elona.api.DungeonMap")
local Dungeon = require("mod.elona.api.Dungeon")
local Rand = require("api.Rand")
local Itemgen = require("mod.tools.api.Itemgen")
local Filters = require("mod.elona.api.Filters")

local dungeon_template = {}

function dungeon_template.type_1(area, floor)
   local gen = Dungeon.gen_type_1
   return DungeonMap.generate(gen, area, floor, {})
end

function dungeon_template.type_2(area, floor)
   local gen = Dungeon.gen_type_2
   return DungeonMap.generate(gen, area, floor, { has_monster_houses = true })
end

local function type_3_calc_density(map)
   local crowd_density = map:calc("max_crowd_density")
   return {
      mob = crowd_density / 2,
      item = crowd_density / 3
   }
end
function dungeon_template.type_3(area, floor)
   local gen = Dungeon.gen_type_3
   return DungeonMap.generate(gen, area, floor, { calc_density = type_3_calc_density })
end

function dungeon_template.type_4(area, floor)
   local gen = Dungeon.gen_type_4
   return DungeonMap.generate(gen, area, floor, {})
end

function dungeon_template.type_5(area, floor)
   local gen = Dungeon.gen_type_5
   return DungeonMap.generate(gen, area, floor, {})
end

function dungeon_template.type_6(area, floor)
   local gen = Dungeon.gen_type_6
   return DungeonMap.generate(gen, area, floor, {})
end

local function type_8_calc_density(map)
   local crowd_density = map:calc("max_crowd_density")
   return {
      mob = crowd_density / 4,
      item = crowd_density / 10
   }
end
function dungeon_template.type_8(area, floor)
   local gen = Dungeon.gen_type_8
   return DungeonMap.generate(gen, area, floor, { calc_density = type_8_calc_density })
end

local function type_9_calc_density(map)
   local crowd_density = map:calc("max_crowd_density")
   return {
      mob = crowd_density / 3,
      item = crowd_density / 10
   }
end
local function type_9_after_generate(map)
   Itemgen.create(nil, nil, {categories=Filters.fsetwear, quality=6})
end
function dungeon_template.type_9(area, floor)
   local gen = Dungeon.gen_type_9
   return DungeonMap.generate(gen, area, floor, { calc_density = type_9_calc_density, after_generate = type_9_after_generate })
end

local function type_10_calc_density(map)
   local crowd_density = map:calc("max_crowd_density")
   return {
      mob = crowd_density / 3,
      item = crowd_density / 6
   }
end
function dungeon_template.type_10(area, floor)
   local gen = Dungeon.gen_type_10
   return DungeonMap.generate(gen, area, floor, { calc_density = type_10_calc_density })
end


function dungeon_template.dungeon(area, floor)
   local tileset = "elona.dungeon"

   local gen = dungeon_template.type_2
   if Rand.one_in(4) then
      gen = dungeon_template.type_1
   end
   if Rand.one_in(6) then
      gen = dungeon_template.type_10
   end
   if Rand.one_in(10) then
      gen = dungeon_template.type_4
   end
   if Rand.one_in(25) then
      gen = dungeon_template.type_8
   end
   if Rand.one_in(25) then
      tileset = "elona.water"
   end

   local map = gen(area, floor)

   if map == nil then
      return nil
   end

   map.tileset = tileset

   return map
end
-- image = "elona.feat_area_cave",

function dungeon_template.tower(area, floor)
   local tileset = "elona.tower_1"

   local gen = dungeon_template.type_1
   if Rand.one_in(5) then
      gen = dungeon_template.type_4
   end
   if Rand.one_in(10) then
      gen = dungeon_template.type_3
   end
   if Rand.one_in(25) then
      gen = dungeon_template.type_2
   end
   if Rand.one_in(40) then
      tileset = "elona.water"
   end

   local map = gen(area, floor)

   if map == nil then
      return nil
   end

   map.tileset = tileset

   return map
end
-- image = "elona.feat_area_tower",

function dungeon_template.forest(area, floor)
   local tileset = "elona.dungeon_forest"

   local gen = dungeon_template.type_2
   if Rand.one_in(6) then
      gen = dungeon_template.type_1
   end
   if Rand.one_in(6) then
      gen = dungeon_template.type_10
   end
   if Rand.one_in(25) then
      gen = dungeon_template.type_8
   end
   if Rand.one_in(20) then
      gen = dungeon_template.type_4
   end

   local map = gen(area, floor)

   if map == nil then
      return nil
   end

   map.tileset = tileset

   return map
end
-- image = "elona.feat_area_tree",

function dungeon_template.castle(area, floor)
   local tileset = "elona.dungeon_castle"

   local gen = dungeon_template.type_1
   if Rand.one_in(5) then
      gen = dungeon_template.type_4
   end
   if Rand.one_in(6) then
      gen = dungeon_template.type_5
   end
   if Rand.one_in(7) then
      gen = dungeon_template.type_2
   end
   if Rand.one_in(40) then
      tileset = "elona.water"
   end

   local map = gen(area, floor)

   if map == nil then
      return nil
   end

   map.tileset = tileset

   return map
end
-- image = "elona.feat_area_temple",

function dungeon_template.lesimas(area, floor)
   local tileset = "elona.lesimas"

   if Rand.one_in(20) then
      tileset = "elona.water"
   end
   if floor < 35 then
      tileset = "elona.dirt"
   end
   if floor < 20 then
      tileset = "elona.tower_1"
   end
   if floor < 10 then
      tileset = "elona.tower_2"
   end
   if floor < 5 then
      tileset = "elona.dirt"
   end

   local gen = dungeon_template.type_1
   if Rand.one_in(30) then
      gen = dungeon_template.type_3
   end

   local levels = {
      [1] = dungeon_template.type_2,
      [5] = dungeon_template.type_5,
      [10] = dungeon_template.type_3,
      [15] = dungeon_template.type_5,
      [20] = dungeon_template.type_3,
      [25] = dungeon_template.type_5,
      [30] = dungeon_template.type_3,
   }

   if levels[floor] then
      gen = levels[floor]
   else
      if floor < 30 and Rand.one_in(4) then
         gen = dungeon_template.type_2
      end

      if Rand.one_in(5) then
         gen = dungeon_template.type_4
      end
      if Rand.one_in(20) then
         gen = dungeon_template.type_8
      end
      if Rand.one_in(6) then
         gen = dungeon_template.type_10
      end
   end

   local map = gen(area, floor)

   if map == nil then
      return nil
   end

   map.tileset = tileset
   map.max_crowd_density = map.max_crowd_density + math.floor(map.level / 2)

   return map
end
-- image = "elona.feat_area_cave",

function dungeon_template.tower_of_fire(area, floor)
   local map = dungeon_template.type_1(area, floor)

   if map == nil then
      return nil
   end

   map.tileset = "elona.tower_of_fire"
   map.max_crowd_density = map.max_crowd_density + math.floor(map.level / 2)

   return map
end

function dungeon_template.crypt_of_the_damned(area, floor)
   local map = dungeon_template.type_1(area, floor)

   if map == nil then
      return nil
   end

   map.tileset = "elona.dirt"
   map.max_crowd_density = map.max_crowd_density + math.floor(map.level / 2)

   return map
end

function dungeon_template.ancient_castle(area, floor)
   local map = dungeon_template.type_1(area, floor)

   if map == nil then
      return nil
   end

   map.tileset = "elona.dungeon_castle"
   map.max_crowd_density = map.max_crowd_density + math.floor(map.level / 2)

   return map
end

return dungeon_template
