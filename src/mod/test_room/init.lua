--- Code for the quickstart scenario.
local Item = require("api.Item")
local Pos = require("api.Pos")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")

local function test_room(self, player)
   local width = 20
   local height = 20
   local map = InstancedMap:new(width, height)
   map:clear("elona.cobble")
   map.is_indoor = true
   map.name = "Test Room"
   for _, x, y in Pos.iter_border(0, 0, width - 1, height - 1) do
      map:set_tile(x, y, "elona.wall_dirt_dark_top")
   end

   player:mod_base_skill_level("elona.stat_magic", 10000)

   data["base.skill"]:iter()
      :filter(function(s) return s.type == "spell" end)
      :each(function(m) player:gain_skill(m._id, 1000) end)

   local item = Item.create("elona.long_bow", nil, nil, {}, player)
   player:equip_item(item)
   item = Item.create("elona.arrow", nil, nil, {}, player)
   player:equip_item(item)

   player:heal_to_max()

   for _, x, y in map:iter_tiles() do
      map:memorize_tile(x, y)
   end

   Map.set_map(map)
   map:take_object(player, width / 2, height / 2)
end

data:add {
   _type = "base.scenario",
   _id = "test_room",

   on_game_start = test_room
}
