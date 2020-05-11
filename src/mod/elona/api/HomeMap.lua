local Chara = require("api.Chara")
local Item = require("api.Item")
local InstancedMap = require("api.InstancedMap")
local Resolver = require("api.Resolver")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

local HomeMap = {}

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
         chara.roles = {["elona.special"] = {}}

         chara = Chara.create("elona.lomias", 16, 11, {}, map)
         chara.roles = {["elona.special"] = {}}

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

function HomeMap.generate(home_id)
   local home = data["elona.home"]:ensure(home_id)

   local map
   if home.map then
      map = Elona122Map.generate(home.map)
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

   return map
end

return HomeMap
