local Advice = require("api.Advice")
local advice_state = require("internal.global.advice_state")
local Calc = require("mod.elona.api.Calc")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")

local function double_fame_income(orig_fn, chara)
   return orig_fn(chara) * 2
end

function test_Advice_add()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Assert.eq(3050, Calc.calc_fame_income(player))

   Advice.add("around", Calc.calc_fame_income, "Double fame income", double_fame_income)
   Assert.eq(6100, Calc.calc_fame_income(player))
end

function test_Advice_add__cleared_between_test_runs()
   print(inspect(advice_state))
   Assert.eq(false, Advice.is_advised(Calc.calc_fame_income))
end

disable("temp")
function test_Advice_remove_by_mod()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Advice.add("around", Calc.calc_fame_income, "Double fame income", double_fame_income)
end
