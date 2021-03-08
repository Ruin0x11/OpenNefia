local Map = require("api.Map")
local Area = require("api.Area")
local Assert = require("api.test.Assert")
local Chara = require("api.Chara")
local StayingCharas = require("api.StayingCharas")
local test_util = require("test.lib.test_util")
local save = require("internal.global.save")

function test_Map_position_in_parent_map()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")

   local puppy_cave_area = Area.create_unique("elona.puppy_cave", north_tyris_area)
   local ok, puppy_cave_map = assert(puppy_cave_area:load_or_generate_floor(puppy_cave_area:starting_floor()))

   Assert.eq(true, ok)
   Assert.is_truthy(puppy_cave_map)

   local x, y = Map.position_in_parent_map(puppy_cave_map)
   Assert.eq(29, x)
   Assert.eq(24, y)
end
