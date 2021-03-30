local Map = require("api.Map")
local Area = require("api.Area")
local Assert = require("api.test.Assert")
local Chara = require("api.Chara")
local StayingCharas = require("api.StayingCharas")
local InstancedMap = require("api.InstancedMap")
local test_util = require("api.test.test_util")

function test_Map_delete__removes_stayers()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))
   local puppy_cave_area = Area.get_unique("elona.puppy_cave", north_tyris_area)
   local _, puppy_cave_floor_one = assert(puppy_cave_area:load_or_generate_floor(1))
   local _, puppy_cave_floor_two = assert(puppy_cave_area:load_or_generate_floor(2))

   Assert.is_truthy(Map.save(north_tyris_map))
   Assert.is_truthy(Map.save(puppy_cave_floor_one))
   Assert.is_truthy(Map.save(puppy_cave_floor_two))

   local chara1 = Chara.create("elona.putit", nil, nil, nil, north_tyris_map)
   local chara2 = Chara.create("elona.putit", nil, nil, nil, north_tyris_map)
   StayingCharas.register_global(chara1, puppy_cave_area, 1)
   StayingCharas.register_global(chara2, puppy_cave_area, 2)

   Assert.eq(puppy_cave_area.uid, StayingCharas.get_staying_area_for_global(chara1).area_uid)
   Assert.eq(1, StayingCharas.get_staying_area_for_global(chara1).area_floor)
   Assert.eq(puppy_cave_area.uid, StayingCharas.get_staying_area_for_global(chara2).area_uid)
   Assert.eq(2, StayingCharas.get_staying_area_for_global(chara2).area_floor)

   Assert.is_truthy(Map.delete(puppy_cave_floor_one.uid))

   Assert.eq(nil, StayingCharas.get_staying_area_for_global(chara1))
   Assert.eq(true, puppy_cave_area:get_floor(1))
   Assert.eq(nil, puppy_cave_area:load_floor(1))
   Assert.eq(false, puppy_cave_area:get_floor(1))
   Assert.eq(puppy_cave_area.uid, StayingCharas.get_staying_area_for_global(chara2).area_uid)
   Assert.eq(2, StayingCharas.get_staying_area_for_global(chara2).area_floor)
end

function test_Map_travel_to__deletes_saved_temporary_maps()
   local temp_uid

   do
      local temp = InstancedMap:new(10, 10)
      temp:clear("elona.cobble")
      temp.is_temporary = true
      temp_uid = temp.uid

      test_util.set_player(temp)
      test_util.register_map(temp)
   end

   test_util.save_cycle()

   do
      local main = InstancedMap:new(10, 10)
      main:clear("elona.cobble")

      Map.travel_to(main)

      local ok, err = Map.load(temp_uid)
      Assert.eq(false, ok)
      Assert.eq(("file does not exist: temp/map/%d"):format(temp_uid), err)
   end
end

function test_Map_travel_to__preserves_saved_nontemporary_maps()
   local map_uid

   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")
      map.is_temporary = false
      map_uid = map.uid

      test_util.set_player(map)
      test_util.register_map(map)
   end

   test_util.save_cycle()

   do
      local main = InstancedMap:new(10, 10)
      main:clear("elona.cobble")

      Map.travel_to(main)

      local ok, map = Map.load(map_uid)
      Assert.eq(true, ok)
      Assert.eq(true, class.is_an(InstancedMap, map))
   end
end
