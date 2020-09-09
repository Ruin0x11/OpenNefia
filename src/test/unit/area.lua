local InstancedMap = require("api.InstancedMap")
local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")
local Test = require("api.test.Test")

data:add {
   _type = "base.area_archetype",
   _id = "test",

   on_generate_floor = function()
      return InstancedMap:new(10, 10)
   end
}
function test_area_autogenerate()
   local area = InstancedArea:new("base.test")
   local ok, map = assert(area:load_or_generate_floor(1))
   Test.assert_eq(Area.for_map(map), area)
end
