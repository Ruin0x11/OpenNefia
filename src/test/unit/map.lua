local Chara = require("api.Chara")
local Item = require("api.Item")
local InstancedMap = require("api.InstancedMap")
local IMapObject = require("api.IMapObject")
local Assert = require("api.test.Assert")

function test_IMapObject_current_map()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)

   Assert.eq(map, IMapObject.current_map(player))

   local item = Item.create("elona.long_bow", nil, nil, {}, player)
   Assert.eq(nil, IMapObject.current_map(item))

   Assert.is_truthy(player:equip_item(item))
   Assert.eq(nil, IMapObject.current_map(item))
end

function test_IMapObject_containing_map()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)
   local containing, obj = IMapObject.containing_map(player)
   Assert.eq(map, player:get_location())
   Assert.eq(map, containing)
   Assert.eq(player, obj)

   local item = Item.create("elona.long_bow", nil, nil, {}, player)
   containing, obj = IMapObject.containing_map(item)
   Assert.eq(player, item:get_location())
   Assert.eq(map, containing)
   Assert.eq(player, obj)

   Assert.is_truthy(player:equip_item(item))
   containing, obj = IMapObject.containing_map(item)
   Assert.eq(player, item:get_location())
   Assert.eq(map, containing)
   Assert.eq(player, obj)
end
