local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local MapObject = require("api.MapObject")
local Queue = require("api.Queue")
local Object = require("api.Object")
local Item = require("api.Item")
local Mef = require("api.Mef")
local Feat = require("api.Feat")

function test_MapObject_clone()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = Chara.create("elona.putit", 1, 2, {}, map)
   chara:mod("max_hp", 123, "set")
   Assert.eq(1, map:iter():length())
   Assert.eq(1, chara.location:iter():length())
   Assert.eq(1, chara.x)
   Assert.eq(2, chara.y)
   Assert.eq(123, chara:calc("max_hp"))

   local new = MapObject.clone(chara)
   Assert.eq(1, map:iter():length())
   Assert.eq(1, chara.location:iter():length())
   Assert.eq(1, new.x)
   Assert.eq(2, new.y)
   Assert.eq(nil, new.location)
   Assert.eq(123, new:calc("max_hp"))

   new:set_pos(3, 4)
   Assert.eq(1, chara.x)
   Assert.eq(2, chara.y)
   Assert.eq(1, new.x) -- because it's not on the map
   Assert.eq(2, new.y) -- because it's not on the map

   chara:remove_ownership()
   Assert.eq(0, map:iter():length())
   Assert.eq(nil, chara.location)
   Assert.eq(nil, new.location)
end

function test_MapObject_clone__owned_chara()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = Chara.create("elona.putit", 1, 2, {}, map)
   Assert.eq(1, map:iter():length())
   Assert.eq(1, chara.location:iter():length())
   Assert.is_truthy(chara.location)
   Assert.eq(map, chara:containing_map())

   local new = MapObject.clone(chara, true)
   Assert.eq(2, map:iter():length())
   Assert.eq(2, chara.location:iter():length())
   Assert.is_truthy(new.x)
   Assert.is_truthy(new.y)
   Assert.eq(chara.location, new.location)
   Assert.eq(chara.__iface, new.__iface)
   Assert.eq(map, new:containing_map())

   new:set_pos(3, 4)
   Assert.eq(1, chara.x)
   Assert.eq(2, chara.y)
   Assert.eq(3, new.x)
   Assert.eq(4, new.y)

   chara:remove_ownership()
   Assert.eq(1, map:iter():length())
   Assert.eq(nil, chara.location)
   Assert.is_truthy(new.location)
   Assert.eq(1, new.location:iter():length())
   Assert.eq(map, new:containing_map())
end

function test_MapObject_clone__owned_item()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = Chara.create("elona.putit", 1, 2, {}, map)
   local item = Item.create("elona.putitoro", nil, nil, {}, chara)
   Assert.eq(1, map:iter():length())
   Assert.eq(1, chara.location:iter():length())
   Assert.eq(1, item.location:iter():length())
   Assert.eq(map, item:containing_map())

   local new = MapObject.clone(item, true)
   Assert.eq(1, map:iter():length())
   Assert.eq(1, chara.location:iter():length())
   Assert.eq(2, item.location:iter():length())
   Assert.eq(0, new.x)
   Assert.eq(0, new.y)
   Assert.eq(item.location, new.location)
   Assert.eq(map, new:containing_map())

   chara:remove_ownership()
   Assert.eq(nil, chara.location)
   Assert.eq(2, item.location:iter():length())
   Assert.eq(nil, item:containing_map())
   Assert.eq(nil, new:containing_map())
end

function test_MapObject_clone__owned_equipment()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = Chara.create("elona.putit", 1, 2, {}, map)
   local item = Item.create("elona.long_bow", nil, nil, {}, chara)
   Assert.is_truthy(chara:equip_item(item))
   Assert.eq(1, chara.location:iter():length())
   Assert.eq(1, item.location:iter():length())
   Assert.eq(0, chara:iter_inventory():length())
   Assert.eq(map, item:containing_map())

   local new = MapObject.clone(item, true)
   Assert.eq(1, map:iter():length())
   Assert.eq(1, chara.location:iter():length())
   Assert.eq(1, item.location:iter():length())
   Assert.eq(1, chara:iter_inventory():length())
   Assert.eq(0, new.x)
   Assert.eq(0, new.y)
   Assert.eq(chara, new:get_location())
   Assert.eq(map, new:containing_map())

   chara:remove_ownership()
   Assert.eq(nil, chara.location)
   Assert.eq(1, item.location:iter():length())
   Assert.eq(1, chara:iter_inventory():length())
   Assert.eq(nil, item:containing_map())
   Assert.eq(nil, new:containing_map())
end

function test_MapObject_is_map_object()
   Assert.eq(false, MapObject.is_map_object(nil))
   Assert.eq(false, MapObject.is_map_object("dood"))
   Assert.eq(false, MapObject.is_map_object(42))
   Assert.eq(false, MapObject.is_map_object(function() end))
   Assert.eq(false, MapObject.is_map_object({}))
   Assert.eq(false, MapObject.is_map_object(Queue:new()))

   local activity = Object.generate_from("base.activity", "elona.traveling")
   Assert.eq(false, MapObject.is_map_object(activity))

   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})
   Assert.eq(true, MapObject.is_map_object(chara))

   local item = Item.create("elona.putitoro", nil, nil, {ownerless=true})
   Assert.eq(true, MapObject.is_map_object(item))

   local feat = Feat.create("elona.quest_board", nil, nil, {ownerless=true})
   Assert.eq(true, MapObject.is_map_object(feat))

   local mef = Mef.create("elona.fire", nil, nil, {ownerless=true})
   Assert.eq(true, MapObject.is_map_object(mef))
end

function test_MapObject_clone__equip_slots()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = Chara.create("elona.putit", 1, 2, {}, map)
   local item = Item.create("elona.long_bow", nil, nil, {}, chara)
   Assert.is_truthy(chara:equip_item(item))
   Assert.eq(1, chara:iter_equipment():length())
   Assert.eq(1, chara:iter_all_body_parts():extract("equipped"):filter(fun.op.truth):length())
   Assert.eq(map, item:containing_map())

   local new = MapObject.clone(chara, true)
   Assert.eq(1, new:iter_equipment():length())
   Assert.eq(1, new:iter_all_body_parts():extract("equipped"):filter(fun.op.truth):length())
end
