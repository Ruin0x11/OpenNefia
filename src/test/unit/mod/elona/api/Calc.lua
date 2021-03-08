local Calc = require("mod.elona.api.Calc")
local Rand = require("api.Rand")
local Assert = require("api.test.Assert")
local test_util = require("test.lib.test_util")
local Rank = require("mod.elona.api.Rank")

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
end
