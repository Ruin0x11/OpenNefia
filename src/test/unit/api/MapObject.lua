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
   Assert.eq(123, chara:calc("max_hp"))

   local new = MapObject.clone(chara)
   Assert.eq(1, map:iter():length())
   Assert.eq(1, chara.location:iter():length())
   Assert.eq(1, new.x)
   Assert.eq(2, new.y)
   Assert.eq(nil, new.location)
   Assert.eq(123, new:calc("max_hp"))
end

function test_MapObject_clone__owned()
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
