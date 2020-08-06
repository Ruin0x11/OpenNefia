--- Code for the quickstart scenario.

local Item = require("api.Item")
local Map = require("api.Map")
local Text = require("mod.elona.api.Text")
local Area = require("api.Area")

local function on_game_start(self, player)
   local bow = Item.create("elona.long_bow", nil, nil, { ownerless = true })
   local arrow = Item.create("elona.arrow", nil, nil, { ownerless = true })
   player:equip_item(bow, true)
   player:equip_item(arrow, true)

   Item.create("elona.putitoro", nil, nil, {}, player)
   Item.create("elona.rod_of_identify", nil, nil, {}, player)
   Item.create("elona.stomafillia", nil, nil, {}, player)

   player:heal_to_max()

   player.title = Text.random_title()

   local root_area = Area.create_unique("test_room.test_room", "root")
   local _, map = assert(root_area:load_or_generate_floor(1))

   local north_tyris = Area.create_unique("elona.north_tyris", root_area)
   assert(Area.create_entrance(north_tyris, 1, 25, 23, {}, map))

   Map.set_map(map)
   map:take_object(player, 25, 25)
end

data:add {
   _type = "base.scenario",
   _id = "test_room",

   on_game_start = on_game_start
}
