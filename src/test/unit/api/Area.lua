local Area = require("api.Area")
local Assert = require("api.test.Assert")
local Chara = require("api.Chara")
local StayingCharas = require("api.StayingCharas")
local Map = require("api.Map")

function test_Area_position_in_parent_map()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   Assert.is_truthy(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))
   local puppy_cave_area = Assert.is_truthy(Area.get_unique("elona.puppy_cave", north_tyris_area))

   Assert.is_truthy(puppy_cave_area)
   local x, y, floor = Area.parent(puppy_cave_area):child_area_position(puppy_cave_area)
   Assert.eq(29, x)
   Assert.eq(24, y)
   Assert.eq(1, floor)
end

function test_Area_delete__clears_child()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   Assert.is_truthy(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))
   local puppy_cave_area = Assert.is_truthy(Area.get_unique("elona.puppy_cave", north_tyris_area))

   Assert.eq(true, north_tyris_area:has_child_area(puppy_cave_area))

   Area.delete(puppy_cave_area)

   Assert.eq(false, north_tyris_area:has_child_area(puppy_cave_area))
end

function test_Area_delete__clears_position_in_parent_map()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   Assert.is_truthy(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))
   local puppy_cave_area = Assert.is_truthy(Area.get_unique("elona.puppy_cave", north_tyris_area))

   local x, y, floor = Area.parent(puppy_cave_area):child_area_position(puppy_cave_area)
   Assert.eq(29, x)
   Assert.eq(24, y)
   Assert.eq(1, floor)

   Area.delete(north_tyris_area)

   Assert.eq(nil, Area.parent(puppy_cave_area))
   x, y, floor = north_tyris_area:child_area_position(puppy_cave_area)
   Assert.eq(nil, x)
   Assert.eq(nil, y)
   Assert.eq(nil, floor)
end

function test_Area_delete__removes_stayers()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   Map.save(north_tyris_map)

   local chara = Chara.create("elona.putit", nil, nil, nil, north_tyris_map)
   StayingCharas.register_global(chara, north_tyris_map)

   Assert.eq(north_tyris_map.uid, StayingCharas.get_staying_map_for_global(chara).map_uid)

   Area.delete(north_tyris_area)

   Assert.eq(nil, StayingCharas.get_staying_map_for_global(chara))
end
