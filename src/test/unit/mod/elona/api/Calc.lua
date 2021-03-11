local Calc = require("mod.elona.api.Calc")
local Rand = require("api.Rand")
local Assert = require("api.test.Assert")
local test_util = require("test.lib.test_util")
local Rank = require("mod.elona.api.Rank")
local save = require("internal.global.save")
local Area = require("api.Area")
local Building = require("mod.elona.api.Building")

function test_Calc_calc_fame_income()
   local chara = test_util.stripped_chara("elona.putit")
   chara.fame = 0

   Assert.eq(100, Calc.calc_fame_income(chara))

   chara.fame = 5000
   Assert.eq(500, Calc.calc_fame_income(chara))

   chara.fame = 30000
   Assert.eq(3050, Calc.calc_fame_income(chara))
end

function test_Calc_calc_rank_income()
   Assert.eq(0, Calc.calc_rank_income("elona.fishing", 10000))
   Assert.eq(4500, Calc.calc_rank_income("elona.fishing", 1000))
   Assert.eq(6930, Calc.calc_rank_income("elona.fishing", 100))
end

function test_Calc_calc_rank_income_proto()
   Assert.eq(0, Calc.calc_rank_income("elona.shop", 10000))
   Assert.eq(900, Calc.calc_rank_income("elona.shop", 1000))
   Assert.eq(1386, Calc.calc_rank_income("elona.shop", 100))
end

function test_Calc_calc_rank_income_items__no_provides()
   Assert.eq(0, #Calc.calc_rank_income_items("elona.shop"))

   Rank.set("elona.shop", 100)
   Rand.set_seed(0)
   Assert.eq(0, #Calc.calc_rank_income_items("elona.arena"))
end

function test_Calc_calc_rank_income_items()
   Rand.set_seed(0)
   Assert.eq(0, #Calc.calc_rank_income_items("elona.arena"))

   Rank.set("elona.arena", 100)
   Rand.set_seed(0)
   Assert.eq(3, #Calc.calc_rank_income_items("elona.arena"))
end

function test_Calc_calc_building_expenses()
   local north_tyris_area = Area.create_unique("elona.north_tyris", "root")
   local ok, north_tyris_map = assert(north_tyris_area:load_or_generate_floor(north_tyris_area:starting_floor()))

   local chara = test_util.stripped_chara("elona.putit")
   Assert.eq(0, Calc.calc_building_expenses(chara))

   save.elona.home_rank = "elona.cyber_house"
   Assert.eq(1600, Calc.calc_building_expenses(chara))

   Building.build("elona.storage_house", 50, 23, north_tyris_map)
   Assert.eq(1975, Calc.calc_building_expenses(chara))

   Building.build("elona.dungeon", 50, 24, north_tyris_map)
   Assert.eq(1975, Calc.calc_building_expenses(chara))

   local area = Building.build("elona.shop", 50, 25, north_tyris_map)
   Assert.eq(4475, Calc.calc_building_expenses(chara))

   chara.karma = 30
   Assert.eq(4027, Calc.calc_building_expenses(chara))

   chara:modify_trait_level("elona.tax", 1)
   Assert.eq(3401, Calc.calc_building_expenses(chara))

   Area.delete(area)
   Assert.eq(1501, Calc.calc_building_expenses(chara))
end

function test_Calc_calc_actual_bill_amount()
   local chara = test_util.stripped_chara("elona.putit")
   chara.level = 1
   chara.fame = 0
   chara.gold = 0

   Rand.set_seed(0)
   Assert.eq(115, Calc.calc_actual_bill_amount(chara))

   chara.level = 10
   Rand.set_seed(0)
   Assert.eq(1150, Calc.calc_actual_bill_amount(chara))

   chara.fame = 1000
   Rand.set_seed(0)
   Assert.eq(1725, Calc.calc_actual_bill_amount(chara))

   chara.gold = 1000000
   Rand.set_seed(0)
   Assert.eq(2300, Calc.calc_actual_bill_amount(chara))

   chara:modify_trait_level("elona.tax", 1)
   Rand.set_seed(0)
   Assert.eq(1978, Calc.calc_actual_bill_amount(chara))

   chara.karma = 30
   Rand.set_seed(0)
   Assert.eq(1748, Calc.calc_actual_bill_amount(chara))
end
