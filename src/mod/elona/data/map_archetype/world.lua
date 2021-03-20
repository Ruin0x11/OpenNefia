local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local util = require("mod.elona.data.map_archetype.util")

do
   data:add {
      _type = "base.map_archetype",
      _id = "north_tyris",
      elona_id = 4,

      starting_pos = MapEntrance.world_map,

      on_generate_map = util.generate_122("ntyris"),

      properties = {
         types = { "world_map" },
         tileset = "elona.world_map",
         turn_cost = 50000,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 0,
      },
   }

   data:add {
      _type = "base.area_archetype",
      _id = "north_tyris",
      elona_id = 4,

      types = { "world_map" },

      floors = {
         [1] = "elona.north_tyris"
      }
   }
end

-- { map = generate_122("elona.vernis"), x = 26, y = 23 },
-- { map = generate_122("elona.yowyn"), x = 43, y = 32 },
-- { map = generate_122("elona.palmia"), x = 53, y = 24 },
-- { map = generate_122("elona.derphy"), x = 14, y = 35 },
-- { map = generate_122("elona.port_kapul"), x = 3, y = 15 },
-- { map = generate_122("elona.noyel"), x = 89, y = 14 },
-- { map = generate_122("elona.lumiest"), x = 61, y = 32 },
-- { map = generate_122("elona.your_home"), x = 22, y = 21 },
-- { map = generate_122("elona.show_house"), x = 35, y = 27 },
-- { map = generate_122("elona.lesimas"), x = 23, y = 29 },
-- { map = generate_122("elona.the_void"), x = 81, y = 51 },
-- { map = generate_122("elona.tower_of_fire"), x = 43, y = 4 },
-- { map = generate_122("elona.crypt_of_the_damned"), x = 38, y = 20 },
-- { map = generate_122("elona.ancient_castle"), x = 26, y = 44 },
-- { map = generate_122("elona.dragons_nest"), x = 13, y = 32 },
-- { map = generate_122("elona.mountain_pass"), x = 64, y = 43 },
-- { map = generate_122("elona.puppy_cave"), x = 29, y = 24 },
-- { map = generate_122("elona.minotaurs_nest"), x = 43, y = 39 },
-- { map = generate_122("elona.yeeks_nest"), x = 38, y = 31 },
-- { map = generate_122("elona.pyramid"), x = 4, y = 11 },
-- { map = generate_122("elona.lumiest_graveyard"), x = 74, y = 31 },
-- { map = generate_122("elona.truce_ground"), x = 51, y = 9 },
-- { map = generate_122("elona.jail"), x = 28, y = 37 },
-- { map = generate_122("elona.cyber_dome"), x = 21, y = 27 },
-- { map = generate_122("elona.larna"), x = 64, y = 47 },
-- { map = generate_122("elona.miral_and_garoks_workshop"), x = 88, y = 25 },
-- { map = generate_122("elona.mansion_of_younger_sister"), x = 18, y = 2 },
-- { map = generate_122("elona.embassy"), x = 53, y = 21 },
-- { map = generate_122("elona.north_tyris_south_border"), x = 27, y = 52 },
-- { map = generate_122("elona.fort_of_chaos_beast"), x = 13, y = 43 },
-- { map = generate_122("elona.fort_of_chaos_machine"), x = 51, y = 32 },
-- { map = generate_122("elona.fort_of_chaos_collapsed"), x = 35, y = 10 },
-- { map = generate_122("elona.test_site"), x = 20, y = 20 },


do
   local south_tyris = {
      _id = "south_tyris",
      _type = "base.map_archetype",
      elona_id = 44,

      on_generate_map = util.generate_122("styris"),

      starting_pos = MapEntrance.world_map,

      properties = {
         types = { "world_map" },
         tileset = "elona.world_map",
         turn_cost = 50000,
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         max_crowd_density = 0,
         default_ai_calm = 0
      }
      -- areas = {
      --    { map = generate_122("elona.south_tyris_north_border"), x = 42, y = 1 },
      --    { map = generate_122("elona.the_smoke_and_pipe"), x = 39, y = 13 },
      -- }
   }

   data:add(south_tyris)

   data:add {
      _type = "base.area_archetype",
      _id = "south_tyris",
      elona_id = 48,

      types = { "world_map" },

      floors = {
         [1] = "elona.south_tyris"
      },
   }
end

do
   local test_world = {
      _id = "test_world",
      _type = "base.map_archetype",
      elona_id = 47,

      on_generate_map = util.generate_122("test"),

      starting_pos = MapEntrance.world_map,

      properties = {
         types = { "world_map" },
         tileset = "elona.world_map",
         turn_cost = 50000,
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 0
      },
   }
   data:add(test_world)

   data:add {
      _type = "base.area_archetype",
      _id = "test_world",
      elona_id = 47,

      types = { "world_map" },

      floors = {
         [1] = "elona.test_world"
      }
   }
end
