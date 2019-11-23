local Rand = require("api.Rand")

local function pick(base, chance, others)
   return function()
      local choices = { base }
      if Rand.one_in(chance) then
         for _, o in ipairs(others) do
            choices[#choices+1] = o
         end
      end

      return Rand.choice(choices)
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

         fog = "wall_stone_4_fog"
      },
      {
         _id = "doors_jail",
         elona_id = 12,

         door = {
            open_tile = "elona.feat_door_jail_open",
            closed_tile = "elona.feat_door_jail_closed",
         }
      },
      {
         _id = "doors_sf",
         elona_id = 8,

         door = {
            open_tile = "elona.feat_door_sf_open",
            closed_tile = "elona.feat_door_sf_closed",
         }
      },
      {
         _id = "doors_eastern",
         elona_id = 9,

         door = {
            open_tile = "elona.feat_door_sf_open",
            closed_tile = "elona.feat_door_sf_closed",
         }
      },
      {
         _id = "dungeon",
         elona_id = 3,

         tiles = {
            ["elona.mapgen_room"] = "elona.dirt",
            ["elona.mapgen_tunnel"] = "elona.dirt",
            ["elona.mapgen_wall"] = "elona.wall_dirt_dark_top",
         },

         fog = "elona.wall_dirt_dark_fog"
      },
      {
         _id = "stone_dirt",
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
            ["elona.mapgen_tunnel"] = pick("elona.dark_dirt_1", 4, {"elona.dark_dirt_2"}),
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
         _id = "dirt",
         elona_id = 0,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_dirt_dark_top",
            ["elona.mapgen_tunnel"] = pick("elona.dark_dirt_1", 4, {"elona.dark_dirt_2"}),
            ["elona.mapgen_wall"] = "elona.wall_dirt_dark_top",
            ["elona.mapgen_room"] = pick("elona.dark_dirt_1", 4, {"elona.dark_dirt_2"}),
         },

         fog = "elona.wall_stone_2_fog"
      },
      {
         _id = "snow",
         elona_id = 6,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_dirt_dark_top",
            ["elona.mapgen_tunnel"] = pick("elona.snow", 3, {"elona.snow_mound"}),
            ["elona.mapgen_wall"] = "elona.wall_dirt_dark_top",
            ["elona.mapgen_room"] = pick("elona.dark_dirt_1", 6, {"elona.dark_dirt_2", "elona.dark_dirt_3"}),
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
            ["elona.mapgen_room"] = pick("elona.tower_of_fire_tile_1", 2, {"elona.tower_of_fire_tile_2"})
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
            ["elona.mapgen_room"] = pick("elona.grass", 6, {"elona.grass_violets", "elona.grass_rocks", "elona.grass_tall_1", "elona.grass_tall_2", "elona.grass_patch_1"})
         },

         fog = "elona.wall_stone_1_fog"
      },
      {
         _id = "dungeon_tower",
         elona_id = 100,

         tiles = {
            ["elona.mapgen_floor"] = "elona.wall_concrete_top",
            ["elona.mapgen_tunnel"] = "elona.cobble_4",
            ["elona.mapgen_wall"] = "elona.wall_concrete_light_top",
            ["elona.mapgen_room"] = pick("elona.tile_1", 3, {"elona.tile_2"})
         },

         fog = "elona.wall_stone_3_fog"
      },
      {
         _id = "lesimas",
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
            ["elona.mapgen_tunnel"] = pick("elona.dark_dirt_1", 4, {"elona.dark_dirt_2"}),
            ["elona.mapgen_wall"] = "elona.wall_stone_1_top",
            ["elona.mapgen_room"] = pick("elona.cobble_dark_1", 4, {"elona.cobble_dark_2"})
         },

         fog = "elona.wall_stone_4_fog"
      },
      {
         _id = "test",
         elona_id = 1,

         tiles = {
            -- ["elona.mapgen_wall"] = "elona.wall_stone_1_top", -- was -1
         },

         fog = pick("elona.wall_oriental_top", 4, "elona.wall_brick_top")
      },
   }
)