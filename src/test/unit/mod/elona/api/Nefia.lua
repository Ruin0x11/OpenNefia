local Nefia = require("mod.elona.api.Nefia")
local Area = require("api.Area")
local Map = require("api.Map")
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local Assert = require("api.test.Assert")
local test_util = require("test.lib.test_util")

function test_Nefia_position_in_parent_map()
   local north_tyris = Area.create_unique("elona.north_tyris", "root")
   local _, north_tyris_map = assert(north_tyris:load_or_generate_floor(north_tyris:starting_floor()))
   local nefia_area = Nefia.create("elona.dungeon", north_tyris, 5, 5)
   Nefia.create_entrance(nefia_area, 50, 20, north_tyris_map)

   local player = test_util.set_player(north_tyris_map, 50, 20)
   Map.set_map(north_tyris_map)
   ElonaCommand.descend(player)

   Assert.eq(nefia_area, Area.current())

   local x, y = Area.position_in_parent_map(Area.current())
   Assert.eq(50, x)
   Assert.eq(20, y)
end
