local InstancedMap = require("api.InstancedMap")
local Rand = require("api.Rand")
local Map = require("api.Map")
local Itemgen = require("mod.tools.api.Itemgen")

data:add_type {
   name = "field_type",
   schema = schema.Record {
      generate = schema.Function,
   },
}

data:extend_type(
   "base.map_tile",
   {
      field_type = schema.Optional(schema.String),
   }
)

local function create_junk_items(map)
   local stood_map_tile = true
   if stood_map_tile then
      for _=1,4+Rand.rnd(5) do
         Itemgen.create(nil, nil, {categories={"elona.junk_in_field"}}, map)
      end
   end
end

local function spray_tile(map, tile_id, density)
   local n = math.floor(map:width() * map:height() * density / 100 + 1)
   print(n,tile_id)

   for i=1,n do
      local x = Rand.rnd(map:width())
      local y = Rand.rnd(map:height())
      map:set_tile(x, y, tile_id)
   end
end

data:add_multi(
   "elona.field_type",
   {
      {
         _id = "plains",

         default_tile = "elona.grass",
         fog = "elona.wall_stone_1_fog",

         tiles = {
            { id = "elona.grass_violets", density = 10 },
            { id = "elona.grass_rocks", density = 2 },
            { id = "elona.grass_tall_1", density = 2 },
            { id = "elona.grass_tall_2", density = 2 },
            { id = "elona.grass_patch_1", density = 2 },
            { id = "elona.grass_patch_2", density = 2 }
         },

         generate = function(self, map)
            map.name = "plains"

            create_junk_items(map)
         end
      },
      {
         _id = "forest",

         default_tile = "elona.grass_bush_1",
         fog = "elona.wall_stone_1_fog",

         tiles = {
            { id = "elona.grass_bush_2", density = 25 },
            { id = "elona.grass", density = 10 },
            { id = "elona.grass_violets", density = 4 },
            { id = "elona.grass_tall_2", density = 2 },
         },

         material_type = "elona.forest",

         generate = function(self, map)
            map.name = "forest"

            create_junk_items(map)
         end
      },
      {
         _id = "sea",

         default_tile = "elona.cracked_dirt_1",
         fog = "elona.wall_stone_1_fog",
         material_type = "elona.forest",

         generate = function(self, map)
            map.name = "sea"
         end
      },
      {
         _id = "grassland",

         default_tile = "elona.grass_tall_1",
         fog = "elona.wall_stone_1_fog",

         tiles = {
            { id = "elona.grass_bush_3", density = 10 },
            { id = "elona.grass_patch_3", density = 10 },
            { id = "elona.grass", density = 30 },
            { id = "elona.grass_violets", density = 4 },
            { id = "elona.grass_tall_2", density = 2 },
            { id = "elona.grass_tall_1", density = 2 },
            { id = "elona.grass_tall_2", density = 2 },
            { id = "elona.grass_patch_1", density = 2 },
         },

         material_type = "elona.field",

         generate = function(self, map)
            map.name = "grassland"

            create_junk_items(map)
         end
      },
      {
         _id = "desert",

         default_tile = "elona.desert",
         fog = "elona.wall_stone_4_fog",

         tiles = {
            { id = "elona.desert_rocks_3", density = 25 },
            { id = "elona.desert_rocks_2", density = 10 },
            { id = "elona.desert", density = 2 },
            { id = "elona.desert_flowers_1", density = 4 },
            { id = "elona.desert_flowers_2", density = 2 },
         },

         material_type = "elona.field",

         generate = function(self, map)
            map.name = "desert"

            create_junk_items(map)
         end
      },
      {
         _id = "snow_field",

         default_tile = "elona.snow",
         fog = "elona.wall_stone_5_fog",

         tiles = {
            { id = "elona.snow_clumps_2", density = 4 },
            { id = "elona.snow_clumps_1", density = 4 },
            { id = "elona.snow_stump", density = 2 },
            { id = "elona.snow_mound", density = 1 },
            { id = "elona.snow_plants", density = 1 },
            { id = "elona.snow_rock", density = 1 },
            { id = "elona.snow_flowers_2", density = 1 },
         },

         generate = function(self, map)
            map.name = "snow_field"

            create_junk_items(map)
         end
      },
   }
)

local default_field_type = "elona.plains"

data:add {
   _type = "base.map_generator",
   _id = "field",

   params = { stood_tile = "string" },
   generate = function(self, params, opts)
      local width = params.width or 34
      local height = params.height or 22

      local stood_tile = Map.tile(params.stood_x, params.stood_y)

      local tile = data["base.map_tile"]:ensure(stood_tile)

      -- TODO: refactor to take base.map_generator
      -- tile spraying could be implemented in Resolver instead
      local field_type = tile.field_type or default_field_type

      local field = data["elona.field_type"][field_type]
      if not field then
         field_type = default_field_type
         field = data["elona.field_type"]:ensure(field_type)
      end

      local map = InstancedMap:new(width, height)
      map:clear(field.default_tile)

      if field.tiles then
         for _, v in ipairs(field.tiles) do
            spray_tile(map, v.id, v.density)
         end
      end

      field:generate(map)

      local x = math.floor(map:width() / 2)
      local y = math.floor(map:height() / 2)
      map.player_start_pos = { x = x, y = y }
      map.is_temporary = true

      map.types = { "field" }
      map.tile_type = 4
      map.max_crowd_density = 4
      map.turn_cost = 10000
      map.dungeon_level = 1
      map.deepest_dungeon_level = 1
      map.is_indoor = true
      map.has_anchored_npcs = false
      map.default_ai_calm = 0
      map.default_tile = field.fog

      map:set_outer_map(params.outer_map or Map.current(), params.stood_x, params.stood_y)

      return map, field_type
   end,

   almost_equals = function(self, other)
      return self.stood_tile == other.stood_tile
   end
}
