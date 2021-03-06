local Area = require("api.Area")
local Assert = require("api.test.Assert")

function test_Area_position_in_parent_map()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local puppy_cave_area = Area.create_unique("elona.puppy_cave", north_tyris_area)

   local x, y = Area.position_in_parent_map(puppy_cave_area)
   Assert.eq(29, x)
   Assert.eq(24, y)
end
