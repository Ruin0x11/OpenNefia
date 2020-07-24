--- Code for the quickstart scenario.
local Item = require("api.Item")
local Pos = require("api.Pos")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")
local Skill = require("mod.elona_sys.api.Skill")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")

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

local function test_room(self, player)

   local item = Item.create("elona.long_bow", nil, nil, {}, player)
   player:equip_item(item)
   item = Item.create("elona.arrow", nil, nil, {}, player)
   player:equip_item(item)

   Item.create("elona.putitoro", nil, nil, {}, player)
   Item.create("elona.rod_of_identify", nil, nil, {}, player)
   Item.create("elona.stomafillia", nil, nil, {}, player)

   player:heal_to_max()

   -- local map = Elona122Map.generate("palmia")
   local map = make_map(50, 50)
   local tx, ty = 18, 22

   for _, x, y in map:iter_tiles() do
      map:memorize_tile(x, y)
   end

   Map.set_map(map)
   map:take_object(player, tx, ty)
end

data:add {
   _type = "base.scenario",
   _id = "test_room",

   on_game_start = test_room
}
