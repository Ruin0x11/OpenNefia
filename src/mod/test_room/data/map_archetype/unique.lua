local Rand = require("api.Rand")
local World = require("api.World")
local Gui = require("api.Gui")
local Pos = require("api.Pos")
local Layout = require("mod.tools.api.Layout")
local Chara = require("api.Chara")
local Area = require("api.Area")
local InstancedMap = require("api.InstancedMap")
local Feat = require("api.Feat")
local Item = require("api.Item")

local arc = {
   _type = "base.map_archetype",
   _id = "test_room"
}

function arc.on_map_renew_minor(map)
   for _=1, 50 do
      local x = Rand.rnd(map:width())
      local y = Rand.rnd(map:height())
      map:set_tile(x, y, "elona.brick_1")
   end
end

function arc.on_map_renew_major(map)
   for _=1, 50 do
      local x = Rand.rnd(map:width())
      local y = Rand.rnd(map:height())
      map:set_tile(x, y, "elona.cobble_caution")
   end
end

function arc.on_map_loaded_events(map)
   local to_minor = map.renew_minor_date - World.date_hours()
   local to_major = map.renew_major_date - World.date_hours()
   Gui.mes_c("Time to minor renew: " .. to_minor .. " hours", "Yellow")
   Gui.mes_c("Time to major renew: " .. to_major .. " hours", "Yellow")
end

function arc.on_map_renew_geometry(map)
   for _, x, y in Pos.iter_rect(10, 10, 20, 20) do
      map:set_tile(x, y, "elona.wall_dirt_dark_top")
   end
end

data:add(arc)


local putit_room = {
   _type = "base.map_archetype",
   _id = "putit_room"
}

function putit_room.on_map_loaded_events(map)
   Gui.mes_c("*puti*", "Yellow")
end

function putit_room.on_generate_map(area, floor)
   local tiles = [[
OOOOOOOOOOOOOOOO
OOOOOOOOOOOOOOOO
OOOOOOOOOOO##OOO
OOOOOOOOOO#..#OO
OOO#######...#OO
OO#..........#OO
O#..x...x....#OO
O#..x...x....#OO
O#..x...x....#OO
O#...........#OO
O#...........#OO
OO#........##OOO
OOO########OOOOO
OOOOOOOOOOOOOOOO
OOOOOOOOOOOOOOOO
OOOOOOOOOOOOOOOO]]

   local tileset = {
      ["."] = "elona.cobble_diagonal",
      ["#"] = "elona.wall_stone_3_top",
      ["O"] = "elona.wall_dirt_dark_top",
      ["x"] = "elona.cyber_4"
   }

   local map = Layout.to_map({tiles = tiles, tileset = tileset})

   for _ = 1, 20 do
      Chara.create("elona.putit", nil, nil, {}, map)
   end

   local parent_area = Area.parent(area) or area
   assert(Area.create_stairs_up(parent_area, 1, 7, 7, { force = true }, map))

   return map
end

putit_room.properties = {
   is_indoor = true,
   turn_cost = 1000000,
   name = "Putit Room",
   default_tile = "elona.wall_stone_3_fog"
}

data:add(putit_room)
data:add {
   _type = "base.area_archetype",
   _id = "putit_room",

   floors = {
      [1] = "test_room.putit_room"
   },

   image = "elona.feat_area_tent",

   parent_area = {
      _id = "test_room.test_room",
      on_floor = 1,
      x = 23,
      y = 25,
      starting_floor = 1
   }
}


local the_dungeon = {
   _type = "base.area_archetype",
   _id = "the_dungeon",
   image = "elona.feat_area_crypt",

   metadata = {
      can_return_to = true
   },
}

function the_dungeon.on_generate_floor(area, floor)
   local map = InstancedMap:new(20, 25)
   map:clear("elona.hardwood_floor_5")
   map.name = "The Dungeon"
   map.is_indoor = true
   map.default_tile = "elona.wall_stone_3_fog"
   map.types = { "dungeon" }

   if floor == 1 then
      local parent_area = Area.parent(area)
      assert(Area.create_stairs_up(parent_area, 1, 5, 5, {}, map))
   end

   if floor > 1 then
      assert(Area.create_stairs_down(area, floor - 1, 12, 15, {}, map))
   end
   if floor < 10 then
      assert(Area.create_stairs_up(area, floor + 1, 8, 15, {}, map))
   end

   return map
end

the_dungeon.parent_area = {
   _id = "test_room.test_room",
   on_floor = 1,
   x = 27,
   y = 25,
   starting_floor = 1
}

data:add(the_dungeon)


local quest_room = {
   _type = "base.map_archetype",
   _id = "quest_room"
}

function quest_room.on_generate_map(area, floor)
   local tiles = [[
OOOOOOOOOOOOOOOO
O..............O
O..............O
O..............O
O..............O
O..............O
O..............O
O..............O
O..............O
O..............O
O..............O
O..............O
O..............O
O..............O
O..............O
OOOOOOOOOOOOOOOO]]

   local tileset = {
      ["."] = "elona.cobble_diagonal",
      ["O"] = "elona.wall_dirt_dark_top"
   }

   local map = Layout.to_map({tiles = tiles, tileset = tileset})

   assert(Feat.create("test_room.select_quest", 7, 7, {}, map))

   assert(Item.create("elona.harmonica", 8, 8, {}, map))
   assert(Item.create("elona.stradivarius", 8, 8, {}, map))

   local parent_area = Area.parent(area) or area
   assert(Area.create_stairs_up(parent_area, 1, 7, 8, { force = true }, map))

   local chara = Chara.create("elona.shopkeeper", nil, nil, {}, map)
   chara:add_role("elona.citizen")

   chara = Chara.create("elona.bartender", nil, nil, {}, map)
   chara:add_role("elona.citizen")

   return map
end

quest_room.properties = {
   is_indoor = true,
   name = "Quest Room",
   default_tile = "elona.wall_stone_3_fog",
   types = { "town" }
}

data:add(quest_room)
data:add {
   _type = "base.area_archetype",
   _id = "quest_room",

   floors = {
      [1] = "test_room.quest_room"
   },

   image = "elona.feat_area_castle",

   metadata = {
      can_return_to = true
   },

   parent_area = {
      _id = "test_room.test_room",
      on_floor = 1,
      x = 27,
      y = 23,
      starting_floor = 1
   }
}


local test_room = {
   _type = "base.area_archetype",
   _id = "test_room",

   metadata = {
      can_return_to = true
   },
}

function test_room.on_generate_floor(area, floor)
   local map = InstancedMap:new(50, 50)
   map:set_archetype("test_room.test_room")
   map:clear("elona.cobble")
   map.is_indoor = true
   map.name = "Test Room"
   for _, x, y in Pos.iter_border(0, 0, 50 - 1, 50 - 1) do
      map:set_tile(x, y, "elona.wall_dirt_dark_top")
   end

   for _, x, y in map:iter_tiles() do
      map:memorize_tile(x, y)
   end

   assert(Feat.create("test_room.select_map", 25, 27, {}, map))

   return map
end

data:add(test_room)
