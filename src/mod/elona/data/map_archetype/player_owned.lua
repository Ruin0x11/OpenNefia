local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local util = require("mod.elona.data.map_archetype.util")
local Item = require("api.Item")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local HomeMap = require("mod.elona.api.HomeMap")

--
-- Your Home
--

local your_home = {
   _id = "your_home",
   _type = "base.map_archetype",
   elona_id = 7,

   starting_pos = MapEntrance.south,

   properties = {
      music = "elona.lonely",
      types = { "player_owned" },
      level = 1,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      tileset = "elona.home",

      is_fixed = true,
      can_return_to = false
   }
}

data:add(your_home)

data:add {
   _type = "base.area_archetype",
   _id = "your_home",

   image = "elona.feat_area_your_dungeon",

   on_generate_floor = function(area, floor)
      local home_rank = save.elona.home_rank
      local map
      if floor == 1 then
         map = HomeMap.generate(home_rank)
      else
         map = HomeMap.generate(home_rank, { no_callbacks = true })
      end

      map:set_archetype("elona.your_home", { set_properties = true })
      return map
   end,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 22,
      y = 21,
      starting_floor = 1
   }
}

--
-- Buildings from deeds
--

do
   local ranch = {
      _id = "ranch",
      _type = "base.map_archetype",
      elona_id = 31,

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.lonely",
         types = { "player_owned" },
         is_indoor = false,
         item_on_floor_limit = 80,
      }
   }
   function ranch.on_generate_map(area, floor)
      local map = Elona122Map.generate("ranch_1")
      map:set_archetype("elona.ranch", { set_properties = true })

      local item = Item.create("elona.book", 23, 8, nil, map)
      item.params.book_id = 11

      Item.create("elona.register", 22, 6, nil, map)

      return map
   end

   data:add(ranch)

   data:add {
      _type = "base.area_archetype",
      _id = "ranch",
      elona_id = 31,

      image = "elona.area_ranch",

      floors = {
         [1] = "elona.ranch"
      }
   }
end

do
   local dungeon = {
      _id = "dungeon",
      _type = "base.map_archetype",
      elona_id = 39,

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.lonely",
         types = { "player_owned" },
         is_indoor = true,
         item_on_floor_limit = 350,
      }
   }

   function dungeon.on_generate_map(area, floor)
      local map = Elona122Map.generate("dungeon1")
      map:set_archetype("elona.dungeon", { set_properties = true })

      local item = Item.create("elona.book", 39, 54, nil, map)
      item.params.book_id = 15

      return map
   end

   data:add(dungeon)

   data:add {
      _type = "base.area_archetype",
      _id = "dungeon",
      elona_id = 39,

      image = "elona.area_your_dungeon",

      floors = {
         [1] = "elona.dungeon"
      }
   }
end

do
   local museum = {
      _id = "museum",
      _type = "base.map_archetype",
      elona_id = 101,

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.town3",
         types = { "player_owned" },
         is_indoor = true,
         item_on_floor_limit = 10,
      }
   }
   function museum.on_generate_map(area, floor)
      local map = Elona122Map.generate("museum_1")
      map:set_archetype("elona.museum", { set_properties = true })

      local item = Item.create("elona.book", 15, 17, nil, map)
      item.params.book_id = 4

      return map
   end

   data:add(museum)

   data:add {
      _type = "base.area_archetype",
      _id = "museum",
      elona_id = 101,

      image = "elona.area_museum",

      floors = {
         [1] = "elona.museum"
      }
   }
end

do
   local shop = {
      _id = "shop",
      _type = "base.map_archetype",
      elona_id = 102,

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.town3",
         types = { "player_owned" },
         is_indoor = true,
         item_on_floor_limit = 10,
      }
   }
   function shop.on_generate_map(area, floor)
      local map = Elona122Map.generate("shop_1")
      map:set_archetype("elona.shop", { set_properties = true })

      local item = Item.create("elona.book", 17, 14, nil, map)
      item.params.book_id = 8

      Item.create("elona.shop_strongbox", 19, 10, nil, map)
      Item.create("elona.register", 17, 11, nil, map)

      return map
   end

   data:add(shop)

   data:add {
      _type = "base.area_archetype",
      _id = "shop",
      elona_id = 102,

      image = "elona.area_shop",

      floors = {
         [1] = "elona.shop"
      }
   }
end

do
   local crop = {
      _id = "crop",
      _type = "base.map_archetype",
      elona_id = 103,

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.lonely",
         types = { "player_owned" },
         is_indoor = false,
         item_on_floor_limit = 80,
      }
   }
   function crop.on_generate_map(area, floor)
      local map = Elona122Map.generate("crop_1")
      map:set_archetype("elona.crop", { set_properties = true })

      local item = Item.create("elona.book", 17, 14, nil, map)
      item.params.book_id = 9

      return map
   end
   data:add(crop)

   data:add {
      _type = "base.area_archetype",
      _id = "crop",
      elona_id = 103,

      image = "elona.area_crop",

      floors = {
         [1] = "elona.crop"
      }
   }
end

do
   local storage = {
      _id = "storage",
      _type = "base.map_archetype",
      elona_id = 104,

      on_generate_map = util.generate_122("storage_1"),

      starting_pos = MapEntrance.south,

      properties = {
         music = "elona.lonely",
         types = { "player_owned" },
         is_indoor = false,
         item_on_floor_limit = 200,
      }
   }

   data:add(storage)

   data:add {
      _type = "base.area_archetype",
      _id = "storage",
      elona_id = 104,

      image = "elona.area_storage_house",

      floors = {
         [1] = "elona.storage"
      }
   }
end
