local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local Chara = require("api.Chara")
local Item = require("api.Item")


local function generate_map(_type, create)
   local object_count = data[_type]:iter():length()
   local size = (math.sqrt(object_count)) * 2

   local map = InstancedMap:new(size + 4, size + 4)
   map:clear("elona.cobble")
   for _, x, y in Pos.iter_border(0, 0, map:width() - 1, map:height() - 1) do
      map:set_tile(x, y, "elona.wall_brick_top")
   end

   local gen, state  = data[_type]:iter()
   local idx = gen(state)

   for y = 2, map:height() - 3, 2 do
      for x = 2, map:width() - 3, 2 do
      map:set_tile(x, y, "elona.hardwood_floor_3")
         if x < map:width() - 2 then
            map:set_tile(x+1, y, "elona.hardwood_floor_2")
         end
         if idx then
            create(x, y, idx, map)
            idx = gen(state, idx)
         end
         map:memorize_tile(x, y)
      end
   end

   return map
end

data:add {
    _type = "base.map_generator",
    _id = "bestiary_item",

    params = {},
    generate = function(self, params, opts)
      local create = function(x, y, _id, map)
         Item.create(_id, x, y, {amount = 1}, map)
      end

      local map = generate_map("base.item", create)
      return map, "bestiary.bestiary_item"
    end,
    load = function(map, params, opts)
    end
}

data:add {
   _type = "elona_sys.map_template",
   _id = "bestiary_item",

   map = {
      generator = "bestiary.bestiary_item"
   },
   image = "elona.feat_area_border_tent",

   copy = {
      music = "elona.ruin",
      types = { "guild" },
      player_start_pos = "base.center",
      dungeon_level = 1,
      is_indoor = true,
      max_crowd_density = 0,
      reveals_fog = true
   },
}

data:add {
  _type = "base.ai_action",
  _id = "null_ai",

  act = function(chara, params)
     return true
  end
}

data:add {
    _type = "base.map_generator",
    _id = "bestiary_chara",

    params = {},
    generate = function(self, params, opts)
      local create = function(x, y, _id, map)
         local chara = Chara.create(_id, x, y, {}, map)
         chara.ai = "bestiary.null_ai"
         chara.faction = "base.neutral"
      end

      local map = generate_map("base.chara", create)
      return map, "bestiary.bestiary_chara"
    end,
    load = function(map, params, opts)
    end
}

data:add {
   _type = "elona_sys.map_template",
   _id = "bestiary_chara",

   map = {
      generator = "bestiary.bestiary_chara"
   },
   image = "elona.feat_area_border_tent",

   copy = {
      music = "elona.ruin",
      types = { "guild" },
      player_start_pos = "base.center",
      dungeon_level = 1,
      is_indoor = true,
      max_crowd_density = 0,
      reveals_fog = true
   },
}