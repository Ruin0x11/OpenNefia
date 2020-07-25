local Chara = require("api.Chara")
local Item = require("api.Item")
local InstancedMap = require("api.InstancedMap")
local IMapObject = require("api.IMapObject")

function test_IMapObject_current_map()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("content.player", 5, 5, {}, map)
   Chara.set_player(player)

   assert(IMapObject.current_map(player) == map)

   local item = Item.create("elona.long_bow", nil, nil, {}, player)
   assert(IMapObject.current_map(item) == nil)

   assert(player:equip_item(item))
   assert(IMapObject.current_map(item) == nil)
end

function test_IMapObject_containing_map()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("content.player", 5, 5, {}, map)
   Chara.set_player(player)
   local containing, obj = IMapObject.containing_map(player)
   assert(player.location == map)
   assert(containing == map)
   assert(obj == player)

   local item = Item.create("elona.long_bow", nil, nil, {}, player)
   containing, obj = IMapObject.containing_map(item)
   assert(item.location == player)
   assert(containing == map)
   assert(obj == player)

   assert(player:equip_item(item))
   containing, obj = IMapObject.containing_map(item)
   assert(item.location == player.equip)
   assert(containing == map)
   assert(obj == player)
end
