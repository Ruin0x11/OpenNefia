local Adventurer = require("mod.elona.api.Adventurer")
local Area = require("api.Area")
local Assert = require("api.test.Assert")
local Map = require("api.Map")
local TestUtil = require("api.test.TestUtil")
local Chara = require("api.Chara")
local IChara = require("api.chara.IChara")

function test_Adventurer__area_of()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")

   Adventurer.initialize()

   local adv = Adventurer.iter_staying():nth(1)
   Assert.is_truthy(adv)
   Assert.eq(north_tyris_area, Adventurer.area_of(adv))
end

function test_Adventurer__area_of__in_map()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")

   Adventurer.initialize()

   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))
   TestUtil.set_player(north_tyris_map)
   Map.set_map(north_tyris_map)

   local vernis_area = Area.create_unique("elona.vernis", north_tyris_area)
   local ok, vernis = assert(vernis_area:load_or_generate_floor(vernis_area:starting_floor()))
   Chara.iter(vernis):each(IChara.remove_ownership)
   Map.save(vernis)

   for _, adv in Adventurer.iter_staying() do
      save.elona.staying_adventurers:register(adv, vernis_area, vernis_area:starting_floor())
   end

   Assert.is_truthy(Map.travel_to(vernis))

   local adv = Adventurer.iter_in_map(vernis):nth(1)
   Assert.is_truthy(adv)
   Assert.eq(vernis_area, Adventurer.area_of(adv))
end

function test_Adventurer__iter_staying()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")

   Adventurer.initialize()

   Assert.eq(Adventurer.MAX_ADVENTURERS, Adventurer.iter_staying():length())
end

function test_Adventurer__iter_in_map()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")

   Adventurer.initialize()

   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))
   TestUtil.set_player(north_tyris_map)
   Map.set_map(north_tyris_map)

   Assert.eq(0, Adventurer.iter_in_map(north_tyris_map):length())

   local vernis_area = Area.create_unique("elona.vernis", north_tyris_area)
   local ok, vernis = assert(vernis_area:load_or_generate_floor(vernis_area:starting_floor()))
   Chara.iter(vernis):each(IChara.remove_ownership)
   Map.save(vernis)

   for _, adv in Adventurer.iter_staying() do
      save.elona.staying_adventurers:register(adv, vernis_area, vernis_area:starting_floor())
   end

   Assert.is_truthy(Map.travel_to(vernis))

   Assert.eq(0, Adventurer.iter_in_map(north_tyris_map):length())
   Assert.eq(Adventurer.MAX_ADVENTURERS, Adventurer.iter_in_map(vernis):length())
   Assert.eq(Adventurer.MAX_ADVENTURERS + 1, Chara.iter(vernis):length())
   Assert.eq(Adventurer.MAX_ADVENTURERS + 1, Chara.iter_all(vernis):length())
   Assert.eq(0, Chara.iter_others(vernis):length())

   Assert.is_truthy(Map.travel_to(north_tyris_map))

   Assert.eq(0, Adventurer.iter_in_map(north_tyris_map):length())
   Assert.eq(0, Adventurer.iter_in_map(vernis):length())
end
