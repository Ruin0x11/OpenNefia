local util = require("mod.elona.data.map_archetype.util")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Dungeon = require("mod.elona.api.Dungeon")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Area = require("api.Area")
local NpcMemory = require("mod.elona_sys.api.NpcMemory")
local Chara = require("api.Chara")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

local lesimas = {
   _type = "base.map_archetype",
   _id = "lesimas",
   elona_id = 3,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon" },
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      can_return_to = true,
      shows_floor_count_in_name = true,
   }
}

function lesimas.chara_filter(map)
   -- >>>>>>>> shade2/map.hsp:30 	if gArea=areaLesimas{ ..
   local level = Calc.calc_object_level(map.level, map)
   local quality = Calc.calc_object_quality(Enum.Quality.Normal)

   if map.level < 4 and level > 5 then
      level = 5
   end

   return {
      level = level,
      quality = quality
   }
   -- <<<<<<<< shade2/map.hsp:33 	}  ..
end

data:add(lesimas)

local area_lesimas = {
   _type = "base.area_archetype",
   _id = "lesimas",

   image = "elona.feat_area_lesimas",

   deepest_floor = 45,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 23,
      y = 29,
      starting_floor = 1
   }
}

local function last_boss_map(area, floor)
   local map = Elona122Map.generate("lesimas_1")
   map:set_archetype("elona.lesimas")
   map.max_crowd_density = 0
   map.is_temporary = true
   map.music = "elona.last_boss"
   map.level = floor

   -- TODO main quest

   assert(Area.create_stairs_up(area, floor - 1, 16, 13, {}, map))

   if NpcMemory.killed("elona.zeome") == 0 then
      assert(Chara.create("elona.zeome", 16, 6, {}, map))
   elseif NpcMemory.killed("elona.orphe") == 0 then
      assert(Chara.create("elona.orphe", 16, 6, {}, map))
   end

   return map
end

function area_lesimas.on_generate_floor(area, floor)
   local map
   if floor == area:archetype().deepest_floor then
      map = last_boss_map(area, floor)
   else
      error("TODO")
      -- map = Dungeon.generate_floor("elona.lesimas", area, floor, "elona.lesimas")
   end

   if floor == 3 then
      local chara = assert(Chara.create("elona.slan", Chara.player().x, Chara.player().y, {}, map))
      chara.roles["elona.special"] = true
      chara.ai_calm = Enum.AiBehavior.Stand
   end

   if floor == 17 then
      local chara = assert(Chara.create("elona.karam", Chara.player().x, Chara.player().y, {}, map))
      chara.roles["elona.special"] = true
      chara.ai_calm = Enum.AiBehavior.Stand
   end

   return map
end

data:add(area_lesimas)


local the_void = {
   _id = "the_void",
   _type = "base.map_archetype",
   elona_id = 42,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon" },
      level = 50,
      is_indoor = true,
      default_ai_calm = 0,
      can_return_to = true,
      prevents_domination = true,
   }
}

function the_void.chara_filter(map)
   local map_level = map.level + Area.floor_number(map)
   local level = Chara.calc_object_level(map_level % 50 + 5, map)
   local quality = Chara.calc_object_quality(Enum.Quality.Normal)
   return {
      level = level,
      quality = quality
   }
end

data:add(the_void)

local area_the_void = {
   _type = "base.area_archetype",
   _id = "the_void",

   image = "elona.feat_area_lesimas",

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 81,
      y = 51,
      starting_floor = 1
   }
}

function area_the_void.on_generate_floor(area, floor)
   error("TODO")
   local map = Dungeon.generate_floor("elona.the_void", area, floor, "elona.the_void")
   -- TODO the void
   return map
end

data:add(area_the_void)


local tower_of_fire = {
   _id = "tower_of_fire",
   _type = "base.map_archetype",
   elona_id = 16,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon_tower" },
      level = 15,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
   }
}

function tower_of_fire.chara_filter(map)
   local level = Calc.calc_object_level(map.level, map)
   local quality = Calc.calc_object_quality(Enum.Quality.Normal)

   return {
      level = level,
      quality = quality,
      tag_filters = {"fire"}
   }
end

data:add(tower_of_fire)

local area_tower_of_fire = {
   _type = "base.area_archetype",
   _id = "tower_of_fire",

   image = "elona.feat_area_tower_of_fire",

   deepest_floor = 4,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 43,
      y = 4,
      starting_floor = 1
   }
}

function area_tower_of_fire.on_generate_floor(area, floor)
   local map
   if floor == area:archetype().deepest_floor then
      map = Elona122Map.generate("firet1")
      map:set_archetype("elona.tower_of_fire")
      map.max_crowd_density = 0
      map.level = floor
      map.music = "elona.last_boss"

      util.connect_existing_stairs(map, area, floor)
   else
      error("TODO")
      map = Dungeon.generate_floor("elona.tower_of_fire", area, floor, "elona.tower_of_fire")
   end
   return map
end

data:add(area_tower_of_fire)


local crypt_of_the_damned = {
   _id = "crypt_of_the_damned",
   _type = "base.map_archetype",
   elona_id = 17,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon" },
      is_indoor = true,
      has_anchored_npcs = true,
      level = 25,
      default_ai_calm = 0,
   }
}

function crypt_of_the_damned.chara_filter(map)
   local level = Calc.calc_object_level(map.level, map)
   local quality = Calc.calc_object_quality(Enum.Quality.Normal)

   return {
      level = level,
      quality = quality,
      tag_filters = {"undead"}
   }
end

data:add(crypt_of_the_damned)

local area_crypt_of_the_damned = {
   _type = "base.area_archetype",
   _id = "crypt_of_the_damned",

   image = "elona.feat_area_crypt",

   deepest_floor = 6,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 38,
      y = 20,
      starting_floor = 1
   }
}

function area_crypt_of_the_damned.on_generate_floor(area, floor)
   error("TODO")
   local map
   if floor == area:archetype().deepest_floor then
      map = Elona122Map.generate("undeadt1")
      map:set_archetype("elona.crypt_of_the_damned")
      map.max_crowd_density = 0
      map.music = "elona.last_boss"
      map.level = floor

      util.connect_existing_stairs(map, area, floor)
   else
      error("TODO")
      map = Dungeon.generate_floor("elona.crypt_of_the_damned", area, floor, "elona.crypt_of_the_damned")
   end
   return map
end

data:add(area_crypt_of_the_damned)


local ancient_castle = {
   _id = "ancient_castle",
   _type = "base.map_archetype",
   elona_id = 18,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon_castle" },
      level = 17,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
   }
}

function ancient_castle.chara_filter(map)
   local level = Calc.calc_object_level(map.level, map)
   local quality = Calc.calc_object_quality(Enum.Quality.Normal)
   local tag_filters = nil

   if Rand.one_in(2) then
      tag_filters = {"man"}
   end

   return {
      level = level,
      quality = quality,
      tag_filters
   }
end

data:add(ancient_castle)


local area_ancient_castle = {
   _type = "base.area_archetype",
   _id = "ancient_castle",

   image = "elona.feat_area_castle",

   deepest_floor = 6,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 26,
      y = 44,
      starting_floor = 1
   }
}

function area_ancient_castle.on_generate_floor(area, floor)
   local map
   if floor == area:archetype().deepest_floor then
      map = Elona122Map.generate("roguet1")
      map:set_archetype("elona.ancient_castle")
      map.max_crowd_density = 0
      map.music = "elona.last_boss"
      map.level = floor

      util.connect_existing_stairs(map, area, floor)
   else
      error("TODO")
      map = Dungeon.generate_floor("elona.ancient_castle", area, floor, "elona.ancient_castle")
   end
   return map
end

data:add(area_ancient_castle)


local dragons_nest = {
   _id = "dragons_nest",
   _type = "base.map_archetype",
   elona_id = 19,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 30,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
   }
}

function dragons_nest.chara_filter(map)
   local level = Calc.calc_object_level(map.level, map)
   local quality = Calc.calc_object_level(Enum.Quality.Normal)
   return {
      level = level,
      quality = quality
   }
end

data:add(dragons_nest)

local area_dragons_nest = {
   _type = "base.area_archetype",
   _id = "dragons_nest",

   image = "elona.feat_area_dungeon",

   deepest_floor = 4,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 13,
      y = 32,
      starting_floor = 1
   }
}

function area_dragons_nest.on_generate_floor(area, floor)
   local map
   error("TODO")
   map = Dungeon.generate_floor("elona.dragons_nest", area, floor, "elona.dragons_nest")
   return map
end

data:add(area_dragons_nest)


local mountain_pass = {
   _id = "mountain_pass",
   _type = "base.map_archetype",
   elona_id = 26,

   starting_pos = MapEntrance.stairs_down,

   properties = {
      types = { "dungeon" },
      level = 25,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0
   }
}
data:add(mountain_pass)

local area_mountain_pass = {
   _type = "base.area_archetype",
   _id = "mountain_pass",

   image = "elona.feat_area_dungeon",

   deepest_floor = 5,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 64,
      y = 43,
      starting_floor = 1
   }
}

function area_mountain_pass.on_generate_floor(area, floor)
   local map
   error("TODO")
   map = Dungeon.generate_floor("elona.type_8", area, floor, "elona.mountain_pass")
   if floor == area:archetype().deepest_floor then
      error("TODO")
   end
   return map
end

data:add(area_mountain_pass)


local puppy_cave = {
   _id = "puppy_cave",
   _type = "base.map_archetype",
   elona_id = 27,

   image = "elona.feat_area_dungeon",
   starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon" },
      level = 2,
      is_indoor = true,
      default_ai_calm = 0,
      is_generated_every_time = true
   },
}

data:add(puppy_cave)

local area_puppy_cave = {
   _type = "base.area_archetype",
   _id = "puppy_cave",

   image = "elona.feat_area_dungeon",

   deepest_floor = 4,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 29,
      y = 24,
      starting_floor = 1
   }
}

function area_puppy_cave.on_generate_floor(area, floor)
   local map
   error("TODO")
   map = Dungeon.generate_floor("elona.type_8", area, floor, "elona.puppy_cave")

   if floor == area:archetype().deepest_floor
      and Sidequest.progress("elona.puppys_cave") < 2
      and not Chara.find("elona.poppy", "allies")
   then
      local poppy = Chara.create("elona.poppy", nil, nil, {}, map, nil, map)
      poppy.is_not_targeted_by_ai = true
   end

   return map
end

data:add(area_puppy_cave)


local minotaurs_nest = {
   _id = "minotaurs_nest",
   _type = "base.map_archetype",
   elona_id = 38,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon" },
      level = 23,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
   }
}

function minotaurs_nest.chara_filter(map)
   local level = Calc.calc_object_level(map.level, map)
   local quality = Calc.calc_object_quality(Enum.Quality.Normal)
   local tag_filters = nil

   if Rand.one_in(2) then
      tag_filters = {"mino"}
   end

   return {
      level = level,
      quality = quality,
      tag_filters
   }
end

data:add(minotaurs_nest)

local area_minotaurs_nest = {
   _type = "base.area_archetype",
   _id = "minotaurs_nest",

   image = "elona.feat_area_dungeon",

   deepest_floor = 5,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 43,
      y = 39,
      starting_floor = 1
   }
}

function area_minotaurs_nest.on_generate_floor(area, floor)
   local map
   error("TODO")
   map = Dungeon.generate_floor("elona.type_9", area, floor, "elona.minotaurs_nest")
   return map
end

data:add(area_minotaurs_nest)


local yeeks_nest = {
   _id = "yeeks_nest",
   _type = "base.map_archetype",
   elona_id = 28,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon" },
      level = 5,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
   }
}

function yeeks_nest.chara_filter(map)
   local level = Calc.calc_object_level(map.level, map)
   local quality = Calc.calc_object_quality(Enum.Quality.Normal)
   local tag_filters = nil

   if Rand.one_in(2) then
      tag_filters = {"yeek"}
   end

   return {
      level = level,
      quality = quality,
      tag_filters
   }
end

data:add(yeeks_nest)

local area_yeeks_nest = {
   _type = "base.area_archetype",
   _id = "yeeks_nest",

   image = "elona.feat_area_dungeon",

   deepest_floor = 1,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 38,
      y = 31,
      starting_floor = 1
   }
}

function area_yeeks_nest.on_generate_floor(area, floor)
   local map
   error("TODO")
   map = Dungeon.generate_floor("elona.default", area, floor, "elona.yeeks_nest")
   return map
end

data:add(area_yeeks_nest)


local pyramid = {
   _id = "pyramid",
   _type = "base.map_archetype",
   elona_id = 37,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      player_start_pos = "elona.stair_up",
      level = 20,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      max_crowd_density = 40,
      prevents_teleport = true,
   }
}

function pyramid.chara_filter(map)
   local level = Calc.calc_object_level(map.level, map)
   local quality = Calc.calc_object_quality(Enum.Quality.Normal)

   return {
      level = level,
      quality = quality,
      category = 13
   }
end

function pyramid.on_generate_map(area, floor)
   local map = Elona122Map.generate("sqPyramid")
   map:set_archetype("elona.pyramid", { set_properties = true })

   for _ = 1, map:calc("max_crowd_density") + 1 do
      util.generate_chara(map)
   end

   util.connect_existing_stairs(map, area, floor)

   return map
end

data:add(pyramid)

local pyramid_2 = {
   _id = "pyramid_2",
   _type = "base.map_archetype",
   -- elona_id = 37,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      level = 21,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      max_crowd_density = 0,
      prevents_teleport = true,
   }
}

function pyramid_2.chara_filter(map)
   local level = Calc.calc_object_level(map.level, map)
   local quality = Calc.calc_object_quality(Enum.Quality.Normal)

   return {
      level = level,
      quality = quality,
      category = 13
   }
end

function pyramid_2.on_generate_map(area, floor)
   local map = Elona122Map.generate("sqPyramid2")
   map:set_archetype("elona.pyramid_2", { set_properties = true })

   util.connect_existing_stairs(map, area, floor)

   return map
end

data:add(pyramid_2)

local area_pyramid = {
   _type = "base.area_archetype",
   _id = "pyramid",

   image = "elona.feat_area_pyramid",

   floors = {
      [1] = "elona.pyramid",
      [2] = "elona.pyramid_2",
   },

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 4,
      y = 11,
      starting_floor = 1
   }
}

data:add(area_pyramid)
