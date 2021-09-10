local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Chara = require("api.Chara")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local util = require("mod.elona.data.map_archetype.util")

do
   local show_house = {
      _type = "base.map_archetype",
      _id = "show_house",
      elona_id = 35,

      on_generate_map = util.generate_122("dungeon1"),

      starting_pos = MapEntrance.south,

      properties = {
         types = { "quest" },
         level = 1,
         is_indoor = true,
         default_ai_calm = "base.calm_roam",
         tileset = "elona.home",
         reveals_fog = true,
         prevents_monster_ball = true,
         is_temporary = true
      }
   }
   data:add(show_house)

   data:add {
      _type = "base.area_archetype",
      _id = "show_house",

      types = { "quest" },
      image = "elona.feat_area_border_tent",

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 35,
         y = 27,
         starting_floor = 1
      }
   }
end

do
   local arena = {
      _type = "base.map_archetype",
      _id = "arena",
      elona_id = 6,

      starting_pos = MapEntrance.center,

      properties = {
         types = { "quest" },
         music = "elona.arena",
         tileset = "elona.tower_1",
         level = 1,
         is_indoor = true,
         default_ai_calm = "base.calm_null",
         max_crowd_density = 0,
         reveals_fog = true,
         is_temporary = true,
         prevents_domination = true,
         prevents_monster_ball = true
      }
   }
   function arena.on_generate_map(area, floor)
      local map = Elona122Map.generate("arena_1")
      map:set_archetype("elona.arena", { set_properties = true })

      -- TODO
      Chara.create("elona.putit", nil, nil, nil, map)

      return map
   end

   data:add(arena)
end

do
   local pet_arena = {
      _type = "base.map_archetype",
      _id = "pet_arena",
      elona_id = 40,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         types = { "quest" },
         music = "elona.arena",
         tileset = "elona.tower_1",
         level = 1,
         is_indoor = true,
         default_ai_calm = "base.calm_null",
         max_crowd_density = 0,
         reveals_fog = true,
         is_temporary = true,
         prevents_teleport = true,
         prevents_domination = true,
         prevents_monster_ball = true
      }
   }
   function pet_arena.on_generate_map(area, floor)
      local map = Elona122Map.generate("arena_2")
      map:set_archetype("elona.pet_arena", { set_properties = true })

      -- TODO
      Chara.create("elona.putit", nil, nil, nil, map)

      return map
   end

   data:add(pet_arena)
end

do
   local quest = {
      _type = "base.map_archetype",
      _id = "quest",
      elona_id = 13,

      starting_pos = MapEntrance.center,

      properties = {
         types = { "quest" },
         tileset = "elona.tower_1",
         level = 1,
         is_indoor = false,
         is_temporary = true,
         max_crowd_density = 0,
         default_ai_calm = "base.calm_null",
         shows_floor_count_in_name = true,
         prevents_building_shelter = true
      }
   }
   data:add(quest)
end

do
   local rq = {
      _id = "rq",
      _type = "base.map_archetype",
      elona_id = 9,

      on_generate_map = util.generate_122("dungeon1"),

      starting_pos = MapEntrance.center,

      properties = {
         types = { "shelter" },
         tileset = "elona.wilderness",
         level = 1,
         is_indoor = false,
         max_crowd_density = 0,
         default_ai_calm = "base.calm_null"
      }
   }

   data:add(rq)

   data:add {
      _type = "base.area_archetype",
      _id = "rq",
      elona_id = 9,

      types = { "field" },
      deepest_floor = 45,

      floors = {
         [1] = "elona.rq"
      }
   }
end
