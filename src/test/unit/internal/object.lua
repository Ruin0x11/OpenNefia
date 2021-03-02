local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local InstancedMap = require("api.InstancedMap")
local test_util = require("test.lib.test_util")

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
      test_util.register_map(map)
      uid = player.uid
   end

   test_util.save_cycle()

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
