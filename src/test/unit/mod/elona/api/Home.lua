local InstancedMap = require("api.InstancedMap")
local Assert = require("api.test.Assert")
local Home = require("mod.elona.api.Home")
local Area = require("api.Area")
local save = require("internal.global.save")

function test_Home_is_home()
   local map = InstancedMap:new(10, 10)

   Assert.eq(false, Home.is_home(map))

   -- TODO should be true in the future, but this will not count homes with
   -- multiple floors.
   save.base.home_map_uid = map.uid
   Assert.eq(false, Home.is_home(map))

   map:set_archetype("elona.your_home")
   Assert.eq(true, Home.is_home(map))
end

function test_Home_is_home_area()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   Assert.eq(false, Home.is_home_area(north_tyris_area))

   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   Assert.eq(true, Home.is_home_area(your_home_area))
end
