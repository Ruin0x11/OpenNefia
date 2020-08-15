local Rand = require("api.Rand")

local function pick(choices, chance)
   return function()
      if Rand.one_in(chance) then
         return Rand.choice(choices)
      end
      return choices[1]
   end
end

data:add_multi(
   "elona_sys.map_tileset",
   {
      {
         _id = "default",

         door = {
            open_tile = "elona.feat_door_wooden_open",
            closed_tile = "elona.feat_door_wooden_closed",
         },

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_oriental_top",
            ["elona.mapgen_wall"] = "elona.wall_stone_1_top",
            ["elona.mapgen_room"] = "elona.cracked_dirt_2",
            ["elona.mapgen_tunnel"] = "elona.dark_dirt_1",
         },

         fog = "elona.wall_stone_4_fog"
      },
      {
         _id = "jail",
         elona_id = 12,

         door = {
            open_tile = "elona.feat_door_jail_open",
            closed_tile = "elona.feat_door_jail_closed",
         }
      },
      {
         _id = "sf",
         elona_id = 8,

         door = {
            open_tile = "elona.feat_door_sf_open",
            closed_tile = "elona.feat_door_sf_closed",
         }
      },
      {
         _id = "eastern",
         elona_id = 9,

         door = {
            open_tile = "elona.feat_door_eastern_open",
            closed_tile = "elona.feat_door_eastern_closed",
         }
      },
      {
         _id = "home",
         elona_id = 3,

         tiles = {
            ["elona.mapgen_room"] = "elona.dirt",
            ["elona.mapgen_tunnel"] = "elona.dirt",
            ["elona.mapgen_wall"] = "elona.wall_dirt_dark_top",
         },

         fog = "elona.wall_dirt_dark_fog"
      },
      {
         _id = "wilderness",
         elona_id = 4,

         tiles = {
            ["elona.mapgen_floor"] = "elona.grass",
         },

         fog = "elona.wall_stone_1_fog"
      },
      {
         _id = "town",
         elona_id = 2,

         tiles = {
            ["elona.mapgen_wall"] = "elona.wall_stone_1_top"
         },

         fog = "elona.wall_stone_2_fog"
      },
      {
         _id = "water",
         elona_id = 10,

         tiles = {
            ["elona.mapgen_room"] = "elona.anime_water_shallow",
            ["elona.mapgen_tunnel"] = pick({"elona.dark_dirt_1","elona.dark_dirt_2","elona.dark_dirt_3","elona.dark_dirt_4"}, 2),
            ["elona.mapgen_wall"] = "elona.wall_dirt_dark_top",
            ["elona.mapgen_floor"] = "elona.wall_dirt_dark_top",
         }
      },
      {
         _id = "castle",
         elona_id = 11,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_stone_4_top",
            ["elona.mapgen_tunnel"] = "elona.tiled_2",
            ["elona.mapgen_wall"] = "elona.wall_wooden_top",
            ["elona.mapgen_room"] = "elona.carpet_green",
         },

         fog = "elona.wall_stone_3_fog"
      },
      {
         _id = "dungeon",
         elona_id = 0,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_dirt_dark_top",
            ["elona.mapgen_tunnel"] = pick({"elona.dark_dirt_1","elona.dark_dirt_2","elona.dark_dirt_3","elona.dark_dirt_4"}, 2),
            ["elona.mapgen_wall"] = "elona.wall_dirt_dark_top",
            ["elona.mapgen_room"] = pick({"elona.dark_dirt_1","elona.dark_dirt_2","elona.dark_dirt_3","elona.dark_dirt_4"}, 2),
         },

         fog = "elona.wall_stone_2_fog"
      },
      {
         _id = "snow",
         elona_id = 6,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_dirt_dark_top",
            ["elona.mapgen_tunnel"] = pick({"elona.snow", "elona.snow_mound", "elona.snow_plants"}, 2),
            ["elona.mapgen_wall"] = "elona.wall_dirt_dark_top",
            ["elona.mapgen_room"] = pick({"elona.dark_dirt_1", "elona.dark_dirt_2", "elona.dark_dirt_3", "elona.dark_dirt_4", "elona.destroyed", "elona.dirt_patch"}, 3),
         },

         fog = "elona.wall_stone_2_fog"
      },
      {
         _id = "tower_of_fire",
         elona_id = 7,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_tower_of_fire_top",
            ["elona.mapgen_tunnel"] = "elona.tower_of_fire_tile_2",
            ["elona.mapgen_wall"] = "elona.wall_tower_of_fire_top",
            ["elona.mapgen_room"] = pick({"elona.tower_of_fire_tile_1", "elona.tower_of_fire_tile_2"}, 2)
         },

         fog = "elona.wall_stone_3_fog"
      },
      {
         _id = "dungeon_forest",
         elona_id = 300,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_forest_top",
            ["elona.mapgen_tunnel"] = "elona.grass",
            ["elona.mapgen_wall"] = "elona.wall_forest_top",
            ["elona.mapgen_room"] = pick({"elona.grass", "elona.grass_violets", "elona.grass_rocks", "elona.grass_tall_1", "elona.grass_tall_2", "elona.grass_patch_1"}, 6)
         },

         fog = "elona.wall_stone_1_fog"
      },
      {
         _id = "noyel_fields",

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_forest_top",
            ["elona.mapgen_tunnel"] = "elona.grass",
            ["elona.mapgen_wall"] = "elona.wall_forest_top",
            ["elona.mapgen_room"] = pick({"elona.snow", "elona.snow_mound", "elona.snow_plants", "elona.snow_rock", "elona.snow_stump", "elona.snow_flowers_1"}, 6)
         },

         fog = "elona.wall_stone_1_fog"
      },
      {
         _id = "tower_1",
         elona_id = 100,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_concrete_top",
            ["elona.mapgen_tunnel"] = "elona.cobble_4",
            ["elona.mapgen_wall"] = "elona.wall_concrete_light_top",
            ["elona.mapgen_room"] = pick({"elona.tile_1", "elona.tile_2", "elona.tile_3"}, 2)
         },

         fog = "elona.wall_stone_3_fog"
      },
      {
         _id = "tower_2",
         elona_id = 101,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_stone_7_top",
            ["elona.mapgen_tunnel"] = "elona.concrete_2",
            ["elona.mapgen_wall"] = "elona.wall_stone_7_top",
            ["elona.mapgen_room"] = "elona.cobble_3"
         },

         fog = "elona.wall_stone_3_fog"
      },
      {
         _id = "dungeon_castle",
         elona_id = 200,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_dirt_top",
            ["elona.mapgen_tunnel"] = pick({ "elona.dark_dirt_1", "elona.dark_dirt_2", "elona.dark_dirt_3", "elona.dark_dirt_4", "elona.destroyed", "elona.dirt_patch" }, 2),
            ["elona.mapgen_wall"] = "elona.wall_stone_1_top",
            ["elona.mapgen_room"] = pick({"elona.cobble_dark_1", "elona.cobble_dark_2", "elona.cobble_dark_3", "elona.cobble_dark_4"}, 2)
         },

         fog = "elona.wall_stone_4_fog"
      },
      {
         _id = "world_map",
         elona_id = 1,

         tiles = {
            -- ["elona.mapgen_wall"] = "elona.wall_stone_1_top", -- was -1
         },

         fog = pick("elona.wall_oriental_top", 4, "elona.wall_brick_top")
      },
   }
)
