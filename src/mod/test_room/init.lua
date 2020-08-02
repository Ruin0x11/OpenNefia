--- Code for the quickstart scenario.
local Item = require("api.Item")
local Pos = require("api.Pos")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")
local Text = require("mod.elona.api.Text")
local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")
local Feat = require("api.Feat")
local Log = require("api.Log")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local World = require("api.World")

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

function arc.on_map_minor_events(map)
   local to_minor = map.renew_minor_date - World.date_hours()
   local to_major = map.renew_major_date - World.date_hours()
   Gui.mes_c("Time to minor renew: " .. to_minor .. " hours", "Gold")
   Gui.mes_c("Time to major renew: " .. to_major .. " hours", "Gold")
end

function arc.on_map_renew_geometry(map)
   for _, x, y in Pos.iter_rect(10, 10, 20, 20) do
      map:set_tile(x, y, "elona.wall_dirt_dark_top")
   end
end

data:add(arc)


local test_room = {
   _type = "base.area_archetype",
   _id = "test_room"
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

   return map
end

data:add(test_room)


local the_dungeon = {
   _type = "base.area_archetype",
   _id = "the_dungeon",
   image = "elona.feat_area_crypt"
}

function the_dungeon.on_generate_floor(area, floor)
   local map = InstancedMap:new(20, 25)
   map:clear("elona.hardwood_floor_5")

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
   start_floor = 1
}

data:add(the_dungeon)


local function test_room(self, player)
   local item = Item.create("elona.long_bow", nil, nil, {}, player)
   player:equip_item(item)
   item = Item.create("elona.arrow", nil, nil, {}, player)
   player:equip_item(item)

   Item.create("elona.putitoro", nil, nil, {}, player)
   Item.create("elona.rod_of_identify", nil, nil, {}, player)
   Item.create("elona.stomafillia", nil, nil, {}, player)

   player:heal_to_max()

   player.title = Text.random_title()

   local root_area = Area.create_unique("test_room.test_room", "root")
   local ok, map = assert(root_area:load_or_generate_floor(1))

   Map.set_map(map)
   map:take_object(player, 25, 25)
end

data:add {
   _type = "base.scenario",
   _id = "test_room",

   on_game_start = test_room
}
