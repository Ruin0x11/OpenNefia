local Chara = require("api.Chara")
local Item = require("api.Item")
local InstancedMap = require("api.InstancedMap")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local I18N = require("api.I18N")
local Log = require("api.Log")

local HomeMap = {}

local function value(level)
   -- >>>>>>>> shade2/item.hsp:647 		iValue(ci)=5000+4500*iParam1(ci)*iParam1(ci)*iPa ..
   return 5000 + 4500 * level * level * level + level * 20000
   -- <<<<<<<< shade2/item.hsp:647 		iValue(ci)=5000+4500*iParam1(ci)*iParam1(ci)*iPa ..
end

data:add {
   _type = "elona.home",
   _id = "cave",

   map = "home0",
   value = value(0),
   image = "elona.feat_area_your_dungeon",

   properties = {
      home_scale = 0,
      max_item_count = 100,
      home_rank_points = 1000
   },

   on_generate = function(map)
      -- >>>>>>>> shade2/map.hsp:877 	 		if gHomeLevel=0{ ..
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

         item = Item.create("elona.book", 18, 19, {}, map)
         item.params = { book_id = 1 }
      end
      -- <<<<<<<< shade2/map.hsp:884 				flt:item_create -1,idBook,18,19:iBookId(ci)=1 ..
   end
}

data:add {
   _type = "elona.home",
   _id = "shack",

   map = "home1",
   value = value(1),
   image = "elona.feat_area_town",

   -- >>>>>>>> shade2/map_user.hsp:7 	if gHomeLevel=1{ ..
   properties = {
      home_scale = 1,
      max_item_count = 150,
      home_rank_points = 3000
   },
   -- <<<<<<<< shade2/map_user.hsp:10 		} ..
}

data:add {
   _type = "elona.home",
   _id = "cozy_house",

   map = "home2",
   value = value(2),

   -- >>>>>>>> shade2/map_user.hsp:11 	if gHomeLevel=2{ ..
   properties = {
      home_scale = 2,
      max_item_count = 200,
      home_rank_points = 5000
   },
   -- <<<<<<<< shade2/map_user.hsp:14 		} ..
}

data:add {
   _type = "elona.home",
   _id = "estate",

   map = "home3",
   value = value(3),

   -- >>>>>>>> shade2/map_user.hsp:15 	if gHomeLevel=3{ ..
   properties = {
      home_scale = 3,
      max_item_count = 300,
      home_rank_points = 7000
   },
   -- <<<<<<<< shade2/map_user.hsp:18 		} ..
}

data:add {
   _type = "elona.home",
   _id = "cyber_house",

   map = "home4",
   value = value(4),
   image = "elona.feat_area_tent",

   -- >>>>>>>> shade2/map_user.hsp:19 	if gHomeLevel=4{ ..
   properties = {
      home_scale = 4,
      max_item_count = 350,
      home_rank_points = 8000,
      tileset = "elona.sf"
   },
   -- <<<<<<<< shade2/map_user.hsp:23 		} ..
}

data:add {
   _type = "elona.home",
   _id = "small_castle",

   map = "home5",
   -- >>>>>>>> shade2/item.hsp:648 		if iParam1(ci)=5:iValue(ci)*=2 ..
   value = value(5) * 2,
   -- <<<<<<<< shade2/item.hsp:648 		if iParam1(ci)=5:iValue(ci)*=2 ..
   image = "elona.feat_area_castle",

   -- >>>>>>>> shade2/map_user.hsp:24 	if gHomeLevel=5{ ..
   properties = {
      home_scale = 0,
      max_item_count = 100,
      home_rank_points = 1000
   },
   -- <<<<<<<< shade2/map_user.hsp:27 		} ..

   on_generate = function(map)
      -- >>>>>>>> shade2/map.hsp:901 			if gHomeLevel=5{ ..
      local chara

      chara = Chara.create("elona.shopkeeper", 31, 20, {}, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.general_vendor" }
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.general_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 9, 20, {}, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.blacksmith" }
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.blacksmith", chara.name)

      chara = Chara.create("elona.shopkeeper", 4, 20, {}, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.goods_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.goods_vendor", chara.name)

      chara = Chara.create("elona.wizard", 4, 11, {}, map)
      chara.roles["elona.wizard"] = true

      chara = Chara.create("elona.bartender", 30, 11, {}, map)
      chara.roles["elona.bartender"] = true

      chara = Chara.create("elona.healer", 30, 4, nil, map)
      chara.roles["elona.healer"] = true

      chara = Chara.create("elona.wizard", 4, 4, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
      chara.shop_rank = 11
      chara.name = I18N.get("chara.job.magic_vendor", chara.name)
      -- <<<<<<<< shade2/map.hsp:909 				} ..
   end
}

function HomeMap.generate(home_id, opts)
   opts = opts or {}

   local home = data["elona.home"]:ensure(home_id)

   local map
   if home.map then
      map = Elona122Map.generate(home.map)
   else
      Log.error("Missing map name for home '%s'", home_id)
      map = InstancedMap:new(30, 20)
      map:clear("elona.grass")
   end

   if home.properties then
      table.merge_ex(map, home.properties)
   end

   if not opts.no_callbacks and home.on_generate then
      home.on_generate(map)
   end

   home.is_travel_destination = true

   return map
end

return HomeMap
