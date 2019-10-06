local Dungeon = require("mod.elona.api.Dungeon")
local Rand = require("api.Rand")
local Map = require("api.Map")

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
      _id = "dungeon",
      _type = "elona.dungeon_template",

      generate = function(self, params, opts)
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
            opts.map_params = { tileset = "10" }
         end

         params.id = kind
         return Map.generate("elona.dungeon_template", params, opts)
      end
   }
)

data:add(
   {
      _id = "forest",
      _type = "elona.dungeon_template",

      generate = function(self, params, opts)
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

         params.id = kind
         return Map.generate("elona.dungeon_template", params, opts)
      end
   }
)

data:add(
   {
      _id = "tower",
      _type = "elona.dungeon_template",

      generate = function(self, params, opts)
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
            opts.map_params = { tileset = "10" }
         end

         params.id = kind
         return Map.generate("elona.dungeon_template", params, opts)
      end
   }
)
