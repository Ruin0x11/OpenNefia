local Area = require("api.Area")
local Assert = require("api.test.Assert")
local save = require("internal.global.save")
local Building = require("mod.elona.api.Building")
local Item = require("api.Item")
local Chara = require("api.Chara")
local Map = require("api.Map")
local Log = require("api.Log")

function test_Building_get_home_area_and_entrances()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   local ok, first_floor = assert(your_home_area:load_or_generate_floor(your_home_area:starting_floor()))

   save.base.home_map_uid = first_floor.uid

   Area.create_entrance(your_home_area, 1, 23, 24, {}, north_tyris_map)

   local area, entrances = Building.find_home_area_and_entrances(north_tyris_map)

   Assert.eq(your_home_area, area)
   Assert.eq(2, #entrances)
   Assert.eq(22, entrances[1].x)
   Assert.eq(21, entrances[1].y)
   Assert.eq(23, entrances[2].x)
   Assert.eq(24, entrances[2].y)
end

function test_Building_build_home()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   local ok, first_floor = assert(your_home_area:load_or_generate_floor(your_home_area:starting_floor()))
   local ok, second_floor = assert(your_home_area:load_or_generate_floor(your_home_area:starting_floor() + 1))

   save.base.home_map_uid = first_floor.uid

   -- Let's create some valuables on both floors.
   Assert.is_truthy(Item.create("elona.putitoro", 10, 10, {amount=2}, first_floor))
   Assert.is_truthy(Item.create("elona.ragnarok", 10, 11, {}, first_floor))
   Assert.is_truthy(Item.create("elona.bow_of_vindale", 10, 12, {}, first_floor))

   Assert.is_truthy(Item.create("elona.raw_ore_of_rubynus", 10, 10, {}, second_floor))
   Assert.is_truthy(Item.create("elona.raw_ore_of_emerald", 10, 11, {}, second_floor))
   Assert.is_truthy(Item.create("elona.raw_ore_of_diamond", 10, 12, {}, second_floor))

   -- And some servants.
   Assert.is_truthy(Chara.create("elona.shopkeeper", 11, 10, {}, first_floor))
   Assert.is_truthy(Chara.create("elona.bartender", 11, 11, {}, first_floor))
   Assert.is_truthy(Chara.create("elona.trainer", 11, 12, {}, first_floor))

   Assert.is_truthy(Chara.create("elona.putit", 11, 10, {}, second_floor))
   Assert.is_truthy(Chara.create("elona.beggar", 11, 11, {}, second_floor))
   Assert.is_truthy(Chara.create("elona.punk", 11, 12, {}, second_floor))

   -- Make sure to save our changes.
   Map.save(north_tyris_map)
   Map.save(first_floor)
   Map.save(second_floor)

   -- And let's check some preconditions.
   Assert.eq(save.base.home_map_uid, first_floor.uid)
   Assert.eq(save.elona.home_rank, "elona.cave")
   Assert.is_truthy(Area.is_created("elona.your_home"))
   Assert.is_truthy(Area.is_registered(your_home_area))

   do
      local area, entrances = Building.find_home_area_and_entrances(north_tyris_map)

      Assert.eq(your_home_area, area)
      Assert.eq(1, #entrances)
      Assert.eq(22, entrances[1].x)
      Assert.eq(21, entrances[1].y)
   end

   Log.set_level("debug")
   -- Now let's upgrade our home.
   local new_home_map, new_home_area = Building.build_home("elona.cyber_house", 23, 24, north_tyris_map)

   Assert.eq(save.base.home_map_uid, new_home_map.uid)
   Assert.eq(save.elona.home_rank, "elona.cyber_house")
   Assert.is_truthy(Area.is_created("elona.your_home"))
   Assert.is_falsy(Area.is_registered(your_home_area))

   do
      local area, entrances = Building.find_home_area_and_entrances(north_tyris_map)

      Assert.not_eq(your_home_area, area)
      Assert.eq(new_home_area, area)
      Assert.eq(1, #entrances)
      Assert.eq(23, entrances[1].x)
      Assert.eq(24, entrances[1].y)
   end

   -- And make sure that all of our items and servants have survived the move.
   local ok, new_first_floor = assert(new_home_area:load_or_generate_floor(new_home_area:starting_floor()))
   local ok, new_second_floor = assert(new_home_area:load_or_generate_floor(new_home_area:starting_floor() + 1))

   local _, map_metadata = new_home_area:get_floor(new_home_area:starting_floor())
   Assert.eq(new_home_map.uid, map_metadata.uid)
   Assert.eq(new_first_floor.uid, map_metadata.uid)

   local first_floor_items = Item.iter(new_first_floor):extract("_id"):to_list()
   local second_floor_items = Item.iter(new_second_floor):extract("_id"):to_list()

   Assert.subset({ "elona.putitoro", "elona.ragnarok", "elona.bow_of_vindale" }, first_floor_items)
   Assert.subset({ "elona.raw_ore_of_rubynus", "elona.raw_ore_of_emerald", "elona.raw_ore_of_diamond", }, second_floor_items)

   local first_floor_charas = Chara.iter_all(new_first_floor):extract("_id"):to_list()
   local second_floor_charas = Chara.iter_all(new_second_floor):extract("_id"):to_list()

   Assert.subset({ "elona.shopkeeper", "elona.bartender", "elona.trainer" }, first_floor_charas)
   Assert.subset({ "elona.putit", "elona.beggar", "elona.punk" }, second_floor_charas)
end
