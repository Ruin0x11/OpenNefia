local StayingCharas = require("api.StayingCharas")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local Map = require("api.Map")
local test_util = require("test.lib.test_util")
local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")

function test_StayingCharas_register()
   local staying = StayingCharas:new()

   local map = InstancedMap:new(10, 10)
   local area = InstancedArea:new()
   Area.register(area, { parent = "root" })
   area:add_floor(map, 1)
   local chara = Chara.create("elona.putit", 2, 7, nil, map)

   Assert.eq(0, staying:iter():length())
   Assert.eq(nil, staying:get_staying_area_for(chara))
   Assert.eq(false, staying:is_staying_in_area(chara, area, 1))
   Assert.eq(false, staying:is_staying_in_map(chara, map))

   staying:register(chara, area, 1)
   Assert.eq(0, staying:iter():length())
   Assert.eq(area.uid, staying:get_staying_area_for(chara).area_uid)
   Assert.eq(1, staying:get_staying_area_for(chara).area_floor)
   Assert.eq(true, staying:is_staying_in_area(chara, area, 1))
   Assert.eq(false, staying:is_staying_in_area(chara, area, 2))
   Assert.eq(true, staying:is_staying_in_map(chara, map))

   staying:unregister(chara, area)
   Assert.eq(0, staying:iter():length())
   Assert.eq(nil, staying:get_staying_area_for(chara))
   Assert.eq(false, staying:is_staying_in_map(chara, map))
   Assert.eq(false, staying:is_staying_in_area(chara, area, 1))
end

function test_StayingCharas_register__invalid()
   local staying = StayingCharas:new()

   local map = InstancedMap:new(10, 10)
   local area = InstancedArea:new()
   Area.register(area, { parent = "root" })
   area:add_floor(map, 1)
   local chara = Chara.create("elona.putit", 2, 7, nil, map)

   Assert.throws_error(function() staying:register(nil, area, 1) end, "'nil' is not a map object")
   Assert.throws_error(function() staying:register(chara, nil, 1) end, "nil %(nil%) is not an instance of Class 'InstancedArea'")
   Assert.throws_error(function() staying:register(chara, area, 42) end, "Floor 42 does not exist in area")
end

function test_StayingCharas_unregister__different_map()
   local staying = StayingCharas:new()

   local map = InstancedMap:new(10, 10)
   local map2 = InstancedMap:new(10, 10)
   local area = InstancedArea:new()
   Area.register(area, { parent = "root" })
   area:add_floor(map, 1)
   area:add_floor(map2, 2)
   local chara = Chara.create("elona.putit", 2, 7, nil, map)

   Assert.eq(0, staying:iter():length())
   Assert.eq(nil, staying:get_staying_area_for(chara))
   Assert.eq(false, staying:is_staying_in_map(chara, map))

   staying:register(chara, area, 1)
   Assert.eq(0, staying:iter():length())
   Assert.eq(area.uid, staying:get_staying_area_for(chara).area_uid)
   Assert.eq(1, staying:get_staying_area_for(chara).area_floor)
   Assert.eq(true, staying:is_staying_in_map(chara, map))

   staying:unregister(chara, area, 2)
   Assert.eq(0, staying:iter():length())
   Assert.eq(area.uid, staying:get_staying_area_for(chara).area_uid)
   Assert.eq(1, staying:get_staying_area_for(chara).area_floor)
   Assert.eq(true, staying:is_staying_in_map(chara, map))
end

function test_StayingCharas_do_transfer()
   local staying = StayingCharas:new()

   local outside = InstancedMap:new(10, 10)
   local inside = InstancedMap:new(10, 10)
   local area_outside = InstancedArea:new()
   Area.register(area_outside, { parent = "root" })
   area_outside:add_floor(outside, 1)
   local area_inside = InstancedArea:new()
   Area.register(area_inside, { parent = area_outside })
   area_inside:add_floor(inside, 1)
   local chara = Chara.create("elona.putit", 2, 7, nil, inside)

   staying:register(chara, area_inside, 1)

   Assert.eq(1, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Alive", chara.state)

   Assert.is_truthy(Map.try_place_chara(chara, 5, 5, outside))
   staying:do_transfer(outside)

   Assert.eq(0, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(1, staying:iter():length())
   Assert.eq("Alive", chara.state)

   staying:do_transfer(inside)

   Assert.eq(1, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Alive", chara.state)
   Assert.eq(2, chara.x)
   Assert.eq(7, chara.y)
end

function test_StayingCharas_do_transfer__will_not_transfer_dead()
   local staying = StayingCharas:new()

   local outside = InstancedMap:new(10, 10)
   local inside = InstancedMap:new(10, 10)
   local area_outside = InstancedArea:new()
   Area.register(area_outside, { parent = "root" })
   area_outside:add_floor(outside, 1)
   local area_inside = InstancedArea:new()
   Area.register(area_inside, { parent = area_outside })
   area_inside:add_floor(inside, 1)
   local chara = Chara.create("elona.putit", 2, 7, nil, inside)

   staying:register(chara, area_inside, 1)
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

   local outside = InstancedMap:new(10, 10)
   local inside = InstancedMap:new(10, 10)
   local area_outside = InstancedArea:new()
   Area.register(area_outside, { parent = "root" })
   area_outside:add_floor(outside, 1)
   local area_inside = InstancedArea:new()
   Area.register(area_inside, { parent = area_outside })
   area_inside:add_floor(inside, 1)
   local chara = test_util.set_player(inside)

   staying:register(chara, area_inside, 1)

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

function test_StayingCharas_do_transfer__fixes_leftover()
   local staying = StayingCharas:new()

   local outside = InstancedMap:new(10, 10)
   local inside = InstancedMap:new(10, 10)
   local other = InstancedMap:new(10, 10)

   local area_outside = InstancedArea:new()
   local area_inside = InstancedArea:new()
   local area_other = InstancedArea:new()

   Area.register(area_outside, { parent = "root" })
   Area.register(area_inside, { parent = area_outside })
   Area.register(area_other, { parent = area_outside })

   area_outside:add_floor(outside, 1)
   area_inside:add_floor(inside, 1)
   area_other:add_floor(other, 1)

   local chara = Chara.create("elona.putit", 2, 7, nil, inside)

   staying:register(chara, area_inside, 1)

   Assert.eq(1, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(0, Chara.iter_all(other):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Alive", chara.state)

   Assert.is_truthy(Map.try_place_chara(chara, 5, 5, outside))
   staying:do_transfer(outside)

   Assert.eq(0, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(0, Chara.iter_all(other):length())
   Assert.eq(1, staying:iter():length())
   Assert.eq("Alive", chara.state)

   staying:unregister(chara)
   staying:do_transfer(other)

   Assert.eq(0, Chara.iter_all(inside):length())
   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(1, Chara.iter_all(other):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Alive", chara.state)
end

function test_StayingCharas_do_transfer__transfers_unregistered()
   local staying = StayingCharas:new()

   local outside = InstancedMap:new(10, 10)

   local area_outside = InstancedArea:new()
   Area.register(area_outside, { parent = "root" })
   area_outside:add_floor(outside, 1)

   local chara = Chara.create("elona.putit", 2, 7, nil, staying)

   Assert.eq(0, Chara.iter_all(outside):length())
   Assert.eq(1, staying:iter():length())
   Assert.eq("Alive", chara.state)

   Assert.is_truthy(Map.try_place_chara(chara, 5, 5, outside))
   staying:do_transfer(outside)

   Assert.eq(1, Chara.iter_all(outside):length())
   Assert.eq(0, staying:iter():length())
   Assert.eq("Alive", chara.state)
   Assert.eq(5, chara.x)
   Assert.eq(5, chara.y)
end
