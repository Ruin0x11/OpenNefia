local Nefia = require("mod.elona.api.Nefia")
local Area = require("api.Area")
local Map = require("api.Map")
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local Feat = require("api.Feat")
local IFeat = require("api.feat.IFeat")
local Assert = require("api.test.Assert")
local test_util = require("api.test.test_util")

function test_Nefia_create__sets_position_in_parent_map()
   local north_tyris = Area.create_unique("elona.north_tyris", "root")
   local _, north_tyris_map = assert(north_tyris:load_or_generate_floor(north_tyris:starting_floor()))
   Map.set_map(north_tyris_map)

   Feat.iter(north_tyris_map):each(IFeat.remove_ownership)
   local player = test_util.set_player(north_tyris_map, 50, 20)
   local nefia_area = Nefia.create("elona.dungeon", north_tyris, 5, 5)
   Nefia.create_entrance(nefia_area, 50, 20, north_tyris_map)
   ElonaCommand.descend(player)

   Assert.eq(nefia_area, Area.current())
   Assert.eq(north_tyris, Area.parent(nefia_area))

   local x, y, floor = Area.parent(nefia_area):child_area_position(nefia_area)
   Assert.eq(50, x)
   Assert.eq(20, y)
   Assert.eq(1, floor)
end
