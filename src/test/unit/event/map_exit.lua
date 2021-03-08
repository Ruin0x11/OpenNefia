local Area = require("api.Area")
local Chara = require("api.Chara")
local test_util = require("test.lib.test_util")
local Map = require("api.Map")
local StayingCharas = require("api.StayingCharas")
local Assert = require("api.test.Assert")
local save = require("internal.global.save")

function test_map_travel_transfers_staying()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local _, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   local puppy_cave_area = Area.create_unique("elona.puppy_cave", north_tyris_area)
   local _, puppy_cave_map = assert(puppy_cave_area:load_or_generate_floor(puppy_cave_area:starting_floor()))

   local player = test_util.set_player(puppy_cave_map)
   local chara = Chara.create("elona.putit", 10, 10, {}, puppy_cave_map)
   Assert.is_truthy(player:recruit_as_ally(chara))
   Map.set_map(puppy_cave_map)

   StayingCharas.register_global(chara, puppy_cave_map)

   Assert.eq("Alive", chara.state)
   Assert.eq(puppy_cave_map, chara:get_location())
   Assert.eq(1, chara:iter_other_party_members():length())

   Assert.is_truthy(Map.travel_to(north_tyris_map))

   Assert.eq("Staying", chara.state)
   Assert.eq(save.base.staying_charas, chara:get_location())
   Assert.eq(0, chara:iter_other_party_members():length())

   Assert.is_truthy(Map.travel_to(puppy_cave_map))

   Assert.eq("Alive", chara.state)
   Assert.eq(puppy_cave_map, chara:get_location())
   Assert.eq(1, chara:iter_other_party_members():length())

   StayingCharas.unregister_global(chara)

   Assert.is_truthy(Map.travel_to(north_tyris_map))

   Assert.eq("Alive", chara.state)
   Assert.eq(north_tyris_map, chara:get_location())
   Assert.eq(1, chara:iter_other_party_members():length())
end
