local Map = require("api.Map")
local Area = require("api.Area")
local Assert = require("api.test.Assert")

function test_Area_position_in_parent_map()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")

   local puppy_cave_area = Area.create_unique("elona.puppy_cave", north_tyris_area)
   local ok, first_floor = puppy_cave_area:load_or_generate_floor(puppy_cave_area:starting_floor())

   Assert.eq(true, ok)
   Assert.is_truthy(first_floor)

   local x, y = Map.position_in_parent_map(first_floor)
   Assert.eq(29, x)
   Assert.eq(24, y)
end
