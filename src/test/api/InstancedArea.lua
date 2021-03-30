local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")
local Assert = require("api.test.Assert")

function test_InstancedArea_set_child_area_position()
   local parent = InstancedArea:new()
   local child = InstancedArea:new()

   parent:add_child_area(child)

   local x, y, floor = parent:child_area_position(child)
   Assert.eq(nil, x)
   Assert.eq(nil, y)
   Assert.eq(nil, floor)

   Assert.throws_error(function() parent:set_child_area_position(child, 25, 40, nil) end)

   parent:set_child_area_position(child, 25, 40, 1)
   x, y, floor = parent:child_area_position(child)
   Assert.eq(25, x)
   Assert.eq(40, y)
   Assert.eq(1, floor)

   parent:set_child_area_position(child, nil)
   x, y, floor = parent:child_area_position(child)
   Assert.eq(nil, x)
   Assert.eq(nil, y)
   Assert.eq(nil, floor)
end

function test_InstancedArea_remove_child_area()
   local parent = InstancedArea:new()
   local child = InstancedArea:new()

   Assert.eq(false, parent:has_child_area(child))

   parent:add_child_area(child)
   Assert.eq(true, parent:has_child_area(child))

   Assert.throws_error(function() parent:add_child_area(child) end, "Area .* is already a child of area .*")

   parent:remove_child_area(child)
   Assert.eq(false, parent:has_child_area(child))

   parent:remove_child_area(child)
   Assert.eq(false, parent:has_child_area(child))
end

function test_InstancedArea_has_type()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   Assert.is_truthy(north_tyris_area:load_or_generate_starting_floor())
   local puppy_cave_area = Area.get_unique("elona.puppy_cave", north_tyris_area)

   Assert.eq(true, north_tyris_area:has_type("world_map"))
   Assert.eq(false, north_tyris_area:has_type("dungeon"))
   Assert.eq(false, north_tyris_area:has_type("dood"))

   Assert.eq(false, puppy_cave_area:has_type("world_map"))
   Assert.eq(true, puppy_cave_area:has_type("dungeon"))
   Assert.eq(false, puppy_cave_area:has_type("dood"))
end
