local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local InstancedMap = require("api.InstancedMap")
local TestUtil = require("api.test.TestUtil")
local Item = require("api.Item")
local Inventory = require("api.Inventory")
local Map = require("api.Map")

function test_object___tostring()
   local putit = Chara.create("elona.putit", nil, nil, {ownerless=true})
   Assert.matches("^<object %('base.chara', uid [0-9]+%) .*>$", tostring(putit))
end

function test_object__get_reserved_field()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local chara = Chara.create("elona.putit", 4, 5, {}, map)

   Assert.eq("elona.putit", chara._id)
   Assert.eq("base.chara", chara._type)
   Assert.is_truthy(chara.uid)
   Assert.is_truthy(chara.__mt)
   Assert.is_truthy(chara.__iface)
   Assert.is_truthy(chara.proto)
   Assert.eq("elona.putit", chara.proto._id)
   Assert.eq("base.chara", chara.proto._type)
   Assert.eq(4, chara.x)
   Assert.eq(5, chara.y)
   Assert.is_truthy(chara.location)
end

local is_reserved = "is a reserved field name on map objects.$"

function test_object__set_reserved_field()
   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})

   Assert.throws_error(function() chara._id = "dood" end, is_reserved)
   Assert.throws_error(function() chara._type = "dood" end, is_reserved)
   Assert.throws_error(function() chara.__mt = "dood" end, is_reserved)
   Assert.throws_error(function() chara.__iface = "dood" end, is_reserved)
   Assert.throws_error(function() chara.proto = "dood" end, is_reserved)
   Assert.throws_error(function() chara.uid = "dood" end, is_reserved)
   Assert.throws_error(function() chara.x = "dood" end, is_reserved)
   Assert.throws_error(function() chara.y = "dood" end, is_reserved)
   Assert.throws_error(function() chara.location = "dood" end, is_reserved)
end

function test_object_serialize()
   local uid
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 4, 5, {}, map)
      Chara.set_player(player)
      TestUtil.register_map(map)
      uid = player.uid
   end

   TestUtil.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()

      Assert.eq("base.player", player._id)
      Assert.eq("base.chara", player._type)
      Assert.eq(uid, player.uid)
      Assert.eq(4, player.x)
      Assert.eq(5, player.y)
      Assert.is_truthy(map)
      Assert.is_truthy(map:has_object(player))

      Assert.throws_error(function() player._id = "dood" end, is_reserved)
      Assert.throws_error(function() player._type = "dood" end, is_reserved)
      Assert.throws_error(function() player.__mt = "dood" end, is_reserved)
      Assert.throws_error(function() player.__iface = "dood" end, is_reserved)
      Assert.throws_error(function() player.proto = "dood" end, is_reserved)
      Assert.throws_error(function() player.uid = "dood" end, is_reserved)
      Assert.throws_error(function() player.x = "dood" end, is_reserved)
      Assert.throws_error(function() player.y = "dood" end, is_reserved)
      Assert.throws_error(function() player.location = "dood" end, is_reserved)
   end
end

function test_object_change_prototype()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")
      TestUtil.set_player(map)
      TestUtil.register_map(map)

      local putit = Chara.create("elona.putit", 5, 5, {}, map)
      Assert.eq("elona.putit", putit._id)
      Assert.eq("elona.putit", putit.proto._id)

      -- Headcanon.
      putit:change_prototype("elona.zeome")
      Assert.eq("elona.zeome", putit._id)
      Assert.eq("elona.zeome", putit.proto._id)
   end

   TestUtil.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()

      local zeome = Chara.find("elona.zeome", "all", map)
      Assert.is_truthy(zeome)
      Assert.eq("elona.zeome", zeome._id)
      Assert.eq("elona.zeome", zeome.proto._id)
   end
end

function test_object_instantiate_events_save()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")
      TestUtil.set_player(map)
      TestUtil.register_map(map)

      local inv = Inventory.get_or_create("@test@.test")
      local gold = Item.create("elona.gold_piece", 5, 5, {}, inv)

      Assert.eq(true, gold:has_event_handler("base.on_get_item"))
   end

   TestUtil.save_cycle()

   do
      local inv = Inventory.get_or_create("@test@.test")
      local gold = inv:iter():nth(1)
      Assert.is_truthy(gold)
      Assert.eq("elona.gold_piece", gold._id)
      Assert.eq(true, gold:has_event_handler("base.on_get_item"))
   end
end

function test_object_instantiate_events_map_load()
   local map_uid

   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")
      TestUtil.set_player(map)
      TestUtil.register_map(map)

      local gold = Item.create("elona.gold_piece", 5, 5, {}, map)

      Assert.eq(true, gold:has_event_handler("base.on_get_item"))

      Map.save(map)
      map_uid = map.uid
   end

   do
      local _, map = assert(Map.load(map_uid))

      local gold = Item.find("elona.gold_piece", "all", map)
      Assert.is_truthy(gold)
      Assert.eq(true, gold:has_event_handler("base.on_get_item"))
   end
end
