local Area = require("api.Area")
local test_util = require("test.lib.test_util")
local Map = require("api.Map")
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local Assert = require("api.test.Assert")

function test_map_entrance_sets_child_area_position()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local _, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))
   local puppy_cave_area = Area.create_unique("elona.puppy_cave", north_tyris_area)

   local x, y, floor = Area.parent(puppy_cave_area):child_area_position(puppy_cave_area)
   Assert.eq(29, x)
   Assert.eq(24, y)
   Assert.eq(1, floor)

   local player = test_util.set_player(north_tyris_map, 29, 24)
   Map.set_map(north_tyris_map)

   ElonaCommand.descend(player)
   Assert.eq(puppy_cave_area, Area.current())

   x, y, floor = Area.parent(puppy_cave_area):child_area_position(puppy_cave_area)
   Assert.eq(29, x)
   Assert.eq(24, y)
   Assert.eq(1, floor)

   ElonaCommand.ascend(player)
   Assert.eq(north_tyris_area, Area.current())
   Assert.eq(29, player.x)
   Assert.eq(24, player.y)
   Assert.eq(1, Map.floor_number(player:current_map()))

   north_tyris_map = player:current_map()
   local feat = Area.create_entrance(puppy_cave_area, 1, 50, 20, {}, north_tyris_map)
   Assert.is_truthy(feat)
   Assert.eq(50, feat.x)
   Assert.eq(20, feat.y)
   Assert.eq(puppy_cave_area.uid, feat.params.area_uid)
   Assert.eq(1, feat.params.area_floor)

   x, y, floor = Area.parent(puppy_cave_area):child_area_position(puppy_cave_area)
   Assert.eq(29, x)
   Assert.eq(24, y)
   Assert.eq(1, floor)

   Map.save(north_tyris_map)

   player:set_pos(50, 20)
   ElonaCommand.descend(player)
   Assert.eq(puppy_cave_area, Area.current())

   x, y, floor = Area.parent(puppy_cave_area):child_area_position(puppy_cave_area)
   Assert.eq(50, x)
   Assert.eq(20, y)
   Assert.eq(1, floor)

   ElonaCommand.ascend(player)
   Assert.eq(north_tyris_area, Area.current())
   Assert.eq(50, player.x)
   Assert.eq(20, player.y)
   Assert.eq(1, Map.floor_number(player:current_map()))

   x, y, floor = Area.parent(puppy_cave_area):child_area_position(puppy_cave_area)
   Assert.eq(50, x)
   Assert.eq(20, y)
   Assert.eq(1, floor)
end
