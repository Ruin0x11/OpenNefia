local Chara = require("api.Chara")
local Item = require("api.Item")
local InstancedMap = require("api.InstancedMap")
local Map = require("api.Map")
local Resolver = require("api.Resolver")

local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
data:add_type {
   name = "home",
   schema = schema.Record {
      map = schema.Optional(schema.String),
      on_generate = schema.Optional(schema.Function),
   }
}

data:add {
   _type = "elona.home",
   _id = "cave",

   map = "home0",

   copy = {
      home_scale = 0,
      max_item_count = 100,
      home_rank_points = 1000
   },

   on_generate = function(map)
      if Sidequest.progress("elona.main_quest") == 0 then
         local chara = Chara.create("elona.larnneire", 18, 10, {}, map)
         chara.roles = {{id = "elona.unique_chara"}}

         chara = Chara.create("elona.lomias", 16, 11, {}, map)
         chara.roles = {{id = "elona.unique_chara"}}

         local item = Item.create("elona.heir_trunk", 6, 10, {}, map)
         item.count = 3

         item = Item.create("elona.salary_chest", 15, 19, {}, map)
         item.count = 4

         item = Item.create("elona.freezer", 9, 8, {}, map)
         item.count = 4

         item = Item.create("elona.book_b", 18, 19, {}, map)
         item.params = { book_id = 1 }
      end
   end
}

data:add {
   _type = "base.map_generator",
   _id = "home",

   params = { id = "string" },
   generate = function(self, params, opts)
      local home = data["elona.home"]:ensure(params.id)

      local map
      if home.map then
         local success
         success, map = Map.generate("elona_sys.elona122", { name = home.map }, opts)
         if not success then
            error(map)
         end
      else
         map = InstancedMap:new(30, 20)
         map:clear("elona.grass")
      end

      if home.copy then
         local copy = Resolver.resolve(home.copy)
         table.merge(map, copy)
      end

      if home.on_generate then
         home.on_generate(map)
      end

      return map, params.id
   end,
   load = function(map, params, opts)
      local home = data["elona.home"]:ensure(params.id)

      -- Copy functions in the "copy" subtable back to the map, since
      -- they will not be serialized (they become nil).
      --
      -- NOTE: but this ignores the fact that maps can be generated in
      -- many ways that may not have a "copy" table available. In that
      -- case a data type for map entrances would have to be created.
      if home.copy then
         local copy = Resolver.resolve(home.copy)

         for k, v in pairs(copy) do
            if type(k) == "string" and k:sub(1, 1) ~= "_" then
               if type(v) == "function" and map[k] == nil then
                  map[k] = v
               end
            end
         end
      end
   end
}
