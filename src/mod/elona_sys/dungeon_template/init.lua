local Feat = require("api.Feat")
local Pos = require("api.Pos")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")
local Rand = require("api.Rand")

data:add_type {
   name = "dungeon_template",
   schema = schema.Record {
      generator = schema.Function
   }
}

data:add_multi(
   "base.map_tile",
   {
      {
         _id = "mapgen_floor",
         image = "mod/elona/graphic/map_tile/0_0.png",
         is_solid = false
      },
      {
         _id = "mapgen_tunnel",
         image = "mod/elona/graphic/map_tile/0_1.png",
         is_solid = false
      },
      {
         _id = "mapgen_wall",
         image = "mod/elona/graphic/map_tile/0_2.png",
         is_solid = true
      },
      {
         _id = "mapgen_room",
         image = "mod/elona/graphic/map_tile/0_3.png",
         is_solid = false
      },
      {
         _id = "mapgen_floor_2",
         image = "mod/elona/graphic/map_tile/0_3.png",
         is_solid = false
      },
})

local function connect_stairs(map, outer_map)
   local pred

   pred = function(feat) return feat._id == "elona.stairs_down" end
   local down = map:iter_feats():filter(pred):nth(1)

   if down then
      down.generator_params = { generator = "elona_sys.dungeon_template", params = {} }
   end

   pred = function(feat) return feat._id == "elona.stairs_up" end
   local up = map:iter_feats():filter(pred):nth(1)
   assert(up)
   up._outer_map_id = outer_map.uid

   return up.x, up.y
end

local function convert_tiles(map)
   local lookup = {
      ["elona_sys.mapgen_floor"] = "elona.hardwood_floor_1",
      ["elona_sys.mapgen_tunnel"] = "elona.red_floor",
      ["elona_sys.mapgen_wall"] = "elona.wall_decor_top",
      ["elona_sys.mapgen_room"] = "elona.cyber_1",
      ["elona_sys.mapgen_floor_2"] = "elona.hardwood_floor_1",
   }

   for _, x, y in Pos.iter_rect(0, 0, map:width() - 1, map:height() - 1) do
      local old = Map.tile(x, y, map)._id
      local new = lookup[old]
      assert(new, old)
      Map.set_tile(x, y, new, map)
   end
end

local function generate_dungeon_raw(id, width, height, gen_params, outer_map)
   local template = data["elona_sys.dungeon_template"]:ensure(id)

   local map = InstancedMap:new(width, height)
   map:clear("elona_sys.mapgen_wall")

   local err
   local rooms = {}

   map, err = template.generate(map, rooms, gen_params)
   if not map then
      return nil, err
   end

   local start_x, start_y = connect_stairs(map, outer_map)

   map.player_start_pos = {
      x = start_x,
      y = start_y
   }

   convert_tiles(map)

   return map
end

local function generate_dungeon(self, params, opts)
   local dungeon

   local keys = data["elona_sys.dungeon_template"]:iter():extract("_id"):to_list()

   while true do
      local id = params.id or Rand.choice(keys)
      local width = params.width or 34 + Rand.rnd(15)
      local height = params.height or 22 + Rand.rnd(15)

      local gen_params = {
         min_size = 3,
         max_size = 4,
         room_count = 3,
         room_entrance_count = 1,
         hidden_path_chance = 5
      }

      local err
      dungeon, err = generate_dungeon_raw(id, width, height, gen_params, opts.outer_map)

      if dungeon then
         break
      end
   end

   return dungeon
end

data:add {
   _type = "base.map_generator",
   _id = "dungeon_template",

   params = {id = "string", width = "number", height = "number"},
   generate = generate_dungeon,

   almost_equals = table.deepcompare
}
