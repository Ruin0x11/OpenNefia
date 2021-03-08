local StayingCharas = require("api.StayingCharas")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local Map = require("api.Map")
local test_util = require("test.lib.test_util")

function test_StayingCharas_register()
   local staying = StayingCharas:new()

   local map = InstancedMap:new(10, 10)
   local chara = Chara.create("elona.putit", nil, nil, nil, map)

   Assert.eq(0, staying:iter():length())
   Assert.eq(nil, staying:get_staying_map_uid_for(chara))

   staying:register(chara, map)
   Assert.eq(0, staying:iter():length())
   Assert.eq(map.uid, staying:get_staying_map_uid_for(chara))

   staying:unregister(chara, map)
   Assert.eq(0, staying:iter():length())
   Assert.eq(nil, staying:get_staying_map_uid_for(chara))
end

function test_StayingCharas_do_transfer()
   local staying = StayingCharas:new()

   local inside = InstancedMap:new(10, 10)
   local outside = InstancedMap:new(10, 10)
   local chara = Chara.create("elona.putit", nil, nil, nil, inside)

   staying:register(chara, inside)

   Assert.eq(1, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Alive", chara.state)

   Assert.is_truthy(Map.try_place_chara(chara, 5, 5, outside))
   staying:do_transfer(outside)

   Assert.eq(0, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(1, staying:iter():length())
   Assert.eq("Staying", chara.state)

   staying:do_transfer(inside)

   Assert.eq(1, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Alive", chara.state)
end

function test_StayingCharas_do_transfer__will_not_transfer_dead()
   local staying = StayingCharas:new()

   local inside = InstancedMap:new(10, 10)
   local outside = InstancedMap:new(10, 10)
   local chara = Chara.create("elona.putit", nil, nil, nil, inside)

   staying:register(chara, inside)
   chara.state = "Dead"

   Assert.eq(1, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Dead", chara.state)

   Assert.is_truthy(Map.try_place_chara(chara, 5, 5, outside))
   staying:do_transfer(outside)

   Assert.eq(0, Chara.iter_all(inside):length())
   Assert.eq(1, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Dead", chara.state)

   Assert.is_truthy(Map.try_place_chara(chara, 5, 5, inside))
   staying:do_transfer(inside)

   Assert.eq(1, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Dead", chara.state)
end

function test_StayingCharas_do_transfer__will_not_transfer_player()
   local staying = StayingCharas:new()

   local inside = InstancedMap:new(10, 10)
   local outside = InstancedMap:new(10, 10)
   local chara = test_util.set_player(inside)

   staying:register(chara, inside)

   Assert.eq(1, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Alive", chara.state)

   Assert.is_truthy(Map.try_place_chara(chara, 5, 5, outside))
   staying:do_transfer(outside)

   Assert.eq(0, Chara.iter_all(inside):length())
   Assert.eq(1, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Alive", chara.state)
end
