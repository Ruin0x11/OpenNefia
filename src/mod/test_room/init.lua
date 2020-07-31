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

local function make_map(width, height)
   local map = InstancedMap:new(width, height)
   map:clear("elona.cobble")
   map.is_indoor = true
   map.name = "Test Room"
   for _, x, y in Pos.iter_border(0, 0, width - 1, height - 1) do
      map:set_tile(x, y, "elona.wall_dirt_dark_top")
   end
   return map
end

local function mkarea(map)
   local floors = {}

   local my_area = Area.for_map(map)
   assert(my_area)
   my_area.image = "elona.item_carrot"

   local area = InstancedArea:new("elona.feat_area_castle")

   for i = 1, 10 do
      floors[i] = InstancedMap:new(20, 30)
      floors[i]:clear("elona.hardwood_floor_5")
   end

   for i = 1, 10 do
      local prev_floor = floors[i-1]
      local next_floor = floors[i+1]

      if prev_floor then
         local stairs = assert(Feat.create("elona.stairs_down", 8, 13, {}, prev_floor))
         stairs.area_uid = area.uid
         stairs.area_floor = i
      end

      if next_floor then
         local stairs = assert(Feat.create("elona.stairs_up", 12, 19, {}, next_floor))
         stairs.area_uid = area.uid
         stairs.area_floor = i
      end
   end

   for floor_number, floor in ipairs(floors) do
      area:add_floor(floor, floor_number)
      if floor_number == 1 then
         assert(Area.create_entrance(my_area, 5, 5, {}, floor))
      end
      Map.save(floor)
   end

   Area.register(area)

   assert(Area.create_entrance(area, math.floor(map:width()/2), math.floor(map:height()/2), {}, map))
end

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

   -- local map = Elona122Map.generate("palmia")
   local map = make_map(50, 50)
   local tx, ty = 22, 22
   Map.save(map)

   for _, x, y in map:iter_tiles() do
      map:memorize_tile(x, y)
   end

   mkarea(map)

   Map.set_map(map)
   map:take_object(player, tx, ty)
end

data:add {
   _type = "base.scenario",
   _id = "test_room",

   on_game_start = test_room
}
