local Area = require("api.Area")
local test_util = require("test.lib.test_util")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local Map = require("api.Map")
local World = require("api.World")

function test_home_preserves_items_on_renew()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   local ok, first_floor = assert(your_home_area:load_or_generate_floor(your_home_area:starting_floor()))

   test_util.set_player(north_tyris_map)
   Map.set_map(north_tyris_map)

   local item = Item.create("elona.putitoro", 10, 10, {}, first_floor)
   local item_count = Item.iter(first_floor):length()

   Assert.is_truthy(Map.travel_to(first_floor))
   Assert.is_truthy(Map.travel_to(north_tyris_map))
   World.pass_time_in_seconds(60 * 60 * 24 * 31 * 2)
   Assert.gt(first_floor.renew_major_date, World.date_hours())
   Assert.is_truthy(Map.travel_to(first_floor))

   Assert.eq(item_count, Item.iter(first_floor):length())
   Assert.is_truthy(item.location)
end

function test_town_removes_items_on_renew()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   local vernis_area = Area.create_unique("elona.vernis", north_tyris_area)
   local ok, vernis = assert(vernis_area:load_or_generate_floor(vernis_area:starting_floor()))

   test_util.set_player(north_tyris_map)
   Map.set_map(north_tyris_map)

   local item = Item.create("elona.putitoro", 10, 10, {}, vernis)

   Assert.is_truthy(Map.travel_to(vernis))
   Assert.is_truthy(Map.travel_to(north_tyris_map))
   World.pass_time_in_seconds(60 * 60 * 24 * 31 * 2)
   Assert.gt(vernis.renew_major_date, World.date_hours())
   Assert.is_truthy(Map.travel_to(vernis))

   Assert.eq(nil, item.location)
end
