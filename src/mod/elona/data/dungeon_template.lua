local Dungeon = require("mod.elona.api.Dungeon")
local Rand = require("api.Rand")
local Map = require("api.Map")
local Itemgen = require("mod.tools.api.Itemgen")
local Filters = require("mod.elona.api.Filters")

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

         return data["elona.dungeon_template"]:ensure(kind).generate(rooms, params, opts)
      end
   }
)

data:add(
   {
      _id = "tower",
      _type = "elona.dungeon_template",

      image = "elona.feat_area_tower",

      generate = function(rooms, params, opts)
         params.tileset = "elona.dungeon_tower"

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

         return data["elona.dungeon_template"]:ensure(kind).generate(rooms, params, opts)
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

         return data["elona.dungeon_template"]:ensure(kind).generate(rooms, params, opts)
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

         return data["elona.dungeon_template"]:ensure(kind).generate(rooms, params, opts)
      end
   }
)

data:add(
   {
      _id = "lesimas",
      _type = "elona.dungeon_template",

      image = "elona.feat_area_cave",

      deepest_dungeon_level = 45,

      generate = function(rooms, params, opts)
         local tileset = "elona.lesimas"

         if Rand.one_in(20) then
            tileset = "elona.water"
         end
         if params.dungeon_level < 35 then
            tileset = "elona.dirt"
         end
         if params.dungeon_level < 20 then
            tileset = "elona.dungeon_tower"
         end
         if params.dungeon_level < 10 then
            tileset = "elona.dungeon_castle"
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

         params.attempts = 1

         local map, err = data["elona.dungeon_template"]:ensure(kind).generate(rooms, params, opts)

         if map then
            map.max_crowd_density = map.max_crowd_density + math.floor(params.dungeon_level / 2)
         end

         return map
      end
   }
)
