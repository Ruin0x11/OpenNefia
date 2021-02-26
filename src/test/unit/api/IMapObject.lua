local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local Item = require("api.Item")
local IMapObject = require("api.IMapObject")

function test_IMapObject_set_pos()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   Assert.eq(0, map:iter_type_at_pos("base.chara", 1, 2):length())
   Assert.eq(0, map:iter_type_at_pos("base.chara", 3, 4):length())

   local obj = Chara.create("elona.putit", 1, 2, {}, map)
   Assert.eq(1, map:iter_type_at_pos("base.chara", 1, 2):length())
   Assert.eq(0, map:iter_type_at_pos("base.chara", 3, 4):length())
   Assert.eq(1, obj.x)
   Assert.eq(2, obj.y)

   obj:set_pos(3, 4)
   Assert.eq(0, map:iter_type_at_pos("base.chara", 1, 2):length())
   Assert.eq(1, map:iter_type_at_pos("base.chara", 3, 4):length())
   Assert.eq(3, obj.x)
   Assert.eq(4, obj.y)

   obj:remove_ownership()
   Assert.eq(0, map:iter_type_at_pos("base.chara", 1, 2):length())
   Assert.eq(0, map:iter_type_at_pos("base.chara", 3, 4):length())
end

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

function test_IMapObject_containing_map__position()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 1, 2, {}, map)
   Chara.set_player(player)
   local _, _, x, y = IMapObject.containing_map(player)
   Assert.eq(1, x)
   Assert.eq(2, y)

   local item = Item.create("elona.long_bow", 3, 4, {}, map)
   _, _, x, y = IMapObject.containing_map(item)
   Assert.eq(3, x)
   Assert.eq(4, y)

   item = Item.create("elona.long_bow", nil, nil, {}, player)
   _, _, x, y = IMapObject.containing_map(item)
   Assert.eq(1, x)
   Assert.eq(2, y)

   Assert.is_truthy(player:equip_item(item))
   _, _, x, y = IMapObject.containing_map(item)
   Assert.eq(1, x)
   Assert.eq(2, y)

   player:set_pos(3, 4)
   _, _, x, y = IMapObject.containing_map(item)
   Assert.eq(3, x)
   Assert.eq(4, y)

   player:remove_ownership()
   _, _, x, y = IMapObject.containing_map(item)
   Assert.eq(nil, x)
   Assert.eq(nil, y)
end
