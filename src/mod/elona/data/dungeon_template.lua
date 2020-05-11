local Dungeon = require("mod.elona.api.Dungeon")
local Rand = require("api.Rand")
local Map = require("api.Map")
local Itemgen = require("mod.tools.api.Itemgen")
local Filters = require("mod.elona.api.Filters")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")

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
         image = "graphic/default/floor.png",
         is_solid = true
      },
      {
         _id = "mapgen_tunnel",
         image = "graphic/default/floor.png",
         is_solid = false
      },
      {
         _id = "mapgen_wall",
         image = "graphic/default/floor.png",
         is_solid = true
      },
      {
         _id = "mapgen_room",
         image = "graphic/default/floor.png",
         is_solid = false
      },
      {
         _id = "mapgen_floor_2",
         image = "graphic/default/floor.png",
         is_solid = false
      },
})

data:add {
   _type = "base.feat",
   _id = "mapgen_block",

   is_solid = true,
   is_opaque = true
}

data:add(
   {
      _id = "type_1",
      _type = "elona.dungeon_template",

      generate = Dungeon.gen_type_1
   }
)

data:add(
   {
      _id = "type_2",
      _type = "elona.dungeon_template",

      generate = Dungeon.gen_type_2,

      has_monster_houses = true
   }
)

data:add(
   {
      _id = "type_3",
      _type = "elona.dungeon_template",

      generate = Dungeon.gen_type_3,

      calc_density = function(map)
         local crowd_density = map:calc("max_crowd_density")
         return {
            mob = crowd_density / 2,
            item = crowd_density / 3
         }
      end
   }
)

data:add(
   {
      _id = "type_4",
      _type = "elona.dungeon_template",

      generate = Dungeon.gen_type_4
   }
)

data:add(
   {
      _id = "type_5",
      _type = "elona.dungeon_template",

      generate = Dungeon.gen_type_5
   }
)

data:add(
   {
      _id = "type_6",
      _type = "elona.dungeon_template",

      generate = Dungeon.gen_type_6
   }
)

data:add(
   {
      _id = "type_8",
      _type = "elona.dungeon_template",

      generate = Dungeon.gen_type_8,

      calc_density = function(map)
         local crowd_density = map:calc("max_crowd_density")
         return {
            mob = crowd_density / 4,
            item = crowd_density / 10
         }
      end
   }
)

data:add(
   {
      _id = "type_9",
      _type = "elona.dungeon_template",

      generate = Dungeon.gen_type_9,

      after_generate = function(map)
         Itemgen.create(nil, nil, {categories=Filters.fsetwear, quality=6})
      end,

      calc_density = function(map)
         local crowd_density = map:calc("max_crowd_density")
         return {
            mob = crowd_density / 3,
            item = crowd_density / 10
         }
      end
   }
)

data:add(
   {
      _id = "type_10",
      _type = "elona.dungeon_template",

      generate = Dungeon.gen_type_10,

      calc_density = function(map)
         local crowd_density = map:calc("max_crowd_density")
         return {
            mob = crowd_density / 3,
            item = crowd_density / 6
         }
      end
   }
)

data:add(
   {
      _id = "dungeon",
      _type = "elona.dungeon_template",

      image = "elona.feat_area_cave",

      generate = function(rooms, params, opts)
         params.tileset = "elona.dungeon"

         local kind = "elona.type_2"
         if Rand.one_in(4) then
            kind = "elona.type_1"
         end
         if Rand.one_in(6) then
            kind = "elona.type_10"
         end
         if Rand.one_in(10) then
            kind = "elona.type_4"
         end
         if Rand.one_in(25) then
            kind = "elona.type_8"
         end
         if Rand.one_in(25) then
            params.tileset = "elona.water"
         end

         return kind, params
      end
   }
)

data:add(
   {
      _id = "tower",
      _type = "elona.dungeon_template",

      image = "elona.feat_area_tower",

      generate = function(rooms, params, opts)
         params.tileset = "elona.tower_1"

         local kind = "elona.type_1"
         if Rand.one_in(5) then
            kind = "elona.type_4"
         end
         if Rand.one_in(10) then
            kind = "elona.type_3"
         end
         if Rand.one_in(25) then
            kind = "elona.type_2"
         end
         if Rand.one_in(40) then
            params.tileset = "elona.water"
         end

         return kind, params
      end
   }
)

data:add(
   {
      _id = "forest",
      _type = "elona.dungeon_template",

      image = "elona.feat_area_tree",

      generate = function(rooms, params, opts)
         params.tileset = "elona.dungeon_forest"

         local kind = "elona.type_2"
         if Rand.one_in(6) then
            kind = "elona.type_1"
         end
         if Rand.one_in(6) then
            kind = "elona.type_10"
         end
         if Rand.one_in(25) then
            kind = "elona.type_8"
         end
         if Rand.one_in(20) then
            kind = "elona.type_4"
         end

         return kind, params
      end
   }
)

data:add(
   {
      _id = "castle",
      _type = "elona.dungeon_template",

      image = "elona.feat_area_temple",

      generate = function(rooms, params, opts)
         params.tileset = "elona.dungeon_castle"

         local kind = "elona.type_1"
         if Rand.one_in(5) then
            kind = "elona.type_4"
         end
         if Rand.one_in(6) then
            kind = "elona.type_5"
         end
         if Rand.one_in(7) then
            kind = "elona.type_2"
         end
         if Rand.one_in(40) then
            params.tileset = "elona.water"
         end

         return kind, params
      end
   }
)

data:add(
   {
      _id = "lesimas",
      _type = "elona.dungeon_template",

      image = "elona.feat_area_cave",

      generate = function(rooms, params, opts)
         local tileset = "elona.lesimas"

         if Rand.one_in(20) then
            tileset = "elona.water"
         end
         if params.dungeon_level < 35 then
            tileset = "elona.dirt"
         end
         if params.dungeon_level < 20 then
            tileset = "elona.tower_1"
         end
         if params.dungeon_level < 10 then
            tileset = "elona.tower_2"
         end
         if params.dungeon_level < 5 then
            tileset = "elona.dirt"
         end

         params.tileset = tileset

         local kind = "elona.type_1"
         if Rand.one_in(30) then
            kind = "elona.type_3"
         end

         local levels = {
            [1] = "elona.type_2",
            [5] = "elona.type_5",
            [10] = "elona.type_3",
            [15] = "elona.type_5",
            [20] = "elona.type_3",
            [25] = "elona.type_5",
            [30] = "elona.type_3",
         }

         if levels[params.dungeon_level] then
            kind = levels[params.dungeon_level]
         else
            if params.dungeon_level < 30 and Rand.one_in(4) then
               kind = "elona.type_2"
            end

            if Rand.one_in(5) then
               kind = "elona.type_4"
            end
            if Rand.one_in(20) then
               kind = "elona.type_8"
            end
            if Rand.one_in(6) then
               kind = "elona.type_10"
            end
         end

         params.max_crowd_density = params.max_crowd_density + math.floor(params.dungeon_level / 2)

         return kind, params
      end
   }
)

data:add(
   {
      _id = "tower_of_fire",
      _type = "elona.dungeon_template",

      generate = function(rooms, params, opts)
         if params.is_deepest_level then
            local map =  Elona122Map.generate("firet1")
            map.max_crowd_density = 0
            map.music = "elona.last_boss"
            return map
         else
            params.tileset = "elona.tower_of_fire"
            params.max_crowd_density = params.max_crowd_density + math.floor(params.dungeon_level / 2)
            return "elona.type_1", params
         end
      end
   }
)

data:add(
   {
      _id = "crypt_of_the_damned",
      _type = "elona.dungeon_template",

      generate = function(rooms, params, opts)
         if params.is_deepest_level then
            local map =  Elona122Map.generate("undeadt1")
            map.max_crowd_density = 0
            map.music = "elona.last_boss"
            return map
         else
            params.tileset = "elona.dirt"
            params.max_crowd_density = params.max_crowd_density + math.floor(params.dungeon_level / 2)
            return "elona.type_1", params
         end
      end
   }
)

data:add(
   {
      _id = "ancient_castle",
      _type = "elona.dungeon_template",

      generate = function(rooms, params, opts)
         if params.is_deepest_level then
            local map =  Elona122Map.generate("undeadt1")
            map.max_crowd_density = 0
            map.music = "elona.last_boss"
            return map
         else
            params.tileset = "elona.dungeon_castle"
            params.max_crowd_density = params.max_crowd_density + math.floor(params.dungeon_level / 2)
            return "elona.type_1", params
         end
      end
   }
)
