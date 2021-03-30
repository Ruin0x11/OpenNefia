local InstancedMap = require("api.InstancedMap")
local Assert = require("api.test.Assert")
local Home = require("mod.elona.api.Home")
local Area = require("api.Area")
local save = require("internal.global.save")
local Inventory = require("api.Inventory")
local Rand = require("api.Rand")
local Rank = require("mod.elona.api.Rank")
local TestUtil = require("api.test.TestUtil")

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

function test_Home_is_home__multiple_floors()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)

   local _, first_floor = your_home_area:load_or_generate_floor(1)
   local _, second_floor = your_home_area:load_or_generate_floor(1)
   local _, third_floor = your_home_area:load_or_generate_floor(1)

   Assert.eq(true, Home.is_home(first_floor))
   Assert.eq(true, Home.is_home(second_floor))
   Assert.eq(true, Home.is_home(third_floor))
end

function test_Home_is_home_area()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   Assert.eq(false, Home.is_home_area(north_tyris_area))

   local your_home_area = Area.create_unique("elona.your_home", north_tyris_area)
   Assert.eq(true, Home.is_home_area(your_home_area))
end

function test_Home_add_salary_to_salary_chest()
   local inv = Inventory:new()
   Assert.eq(0, inv:len())

   Rand.set_seed(0)
   Rank.set("elona.arena", 1000)
   Rank.set("elona.pet_arena", 1000)
   Rank.set("elona.shop", 1000)
   Home.add_salary_to_salary_chest(inv)

   Assert.eq(4, inv:len())

   local gold = inv:iter():filter(function(i) return i._id == "elona.gold_piece" end):nth(1)
   Assert.is_truthy(gold)
   Assert.eq(7611, gold.amount)
end

function test_Home_add_monthly_bill_to_salary_chest_and_update()
   local chara = TestUtil.stripped_chara("elona.putit")
   chara.fame = 1000
   chara.karma = 20

   local inv = Inventory:new()
   Assert.eq(0, inv:len())
   Assert.eq(0, save.elona.unpaid_bill_count)

   Rand.set_seed(0)
   Home.add_monthly_bill_to_salary_chest_and_update(inv, chara)
   Assert.eq(1, inv:len())
   Assert.eq(1, save.elona.unpaid_bill_count)
   Assert.eq(1000, chara.fame)
   Assert.eq(20, chara.karma)
   local bill = inv:iter():nth(1)
   Assert.eq(599, bill.params.bill_gold_amount)

   Home.add_monthly_bill_to_salary_chest_and_update(inv, chara)
   Assert.eq(2, inv:len())
   Assert.eq(2, save.elona.unpaid_bill_count)
   Assert.eq(1000, chara.fame)
   Assert.eq(20, chara.karma)

   Home.add_monthly_bill_to_salary_chest_and_update(inv, chara)
   Assert.eq(3, inv:len())
   Assert.eq(3, save.elona.unpaid_bill_count)
   Assert.eq(1000, chara.fame)
   Assert.eq(20, chara.karma)

   Home.add_monthly_bill_to_salary_chest_and_update(inv, chara)
   Assert.eq(4, inv:len())
   Assert.eq(4, save.elona.unpaid_bill_count)
   Assert.eq(1000, chara.fame)
   Assert.eq(20, chara.karma)

   Home.add_monthly_bill_to_salary_chest_and_update(inv, chara)
   Assert.eq(5, inv:len())
   Assert.eq(5, save.elona.unpaid_bill_count)
   Assert.lt(1000, chara.fame)
   Assert.eq(-40, chara.karma)
end
