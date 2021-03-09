local Advice = require("api.Advice")
local advice_state = require("internal.global.advice_state")
local Calc = require("mod.elona.api.Calc")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local test_util = require("test.lib.test_util")

local function double_fame_income(orig_fn, chara)
   return orig_fn(chara) * 2
end

local function flat_fame_income(chara)
   return 9999
end

function test_Advice_add()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   local fn = Calc.calc_fame_income

   Assert.eq(3050, Calc.calc_fame_income(player))
   Assert.eq(fn, Calc.calc_fame_income)

   Assert.is_truthy(Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income))
   Assert.eq(6100, Calc.calc_fame_income(player))
   Assert.not_eq(fn, Calc.calc_fame_income)
end

function test_Advice_add__cleared_between_test_runs()
   Assert.eq(false, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income"))
end

function test_Advice_is_advised()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Assert.eq(false, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income"))
   Assert.eq(false, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Double fame income"))
   Assert.eq(false, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "dood"))
   Assert.eq(false, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income", "dood", "Double fame income"))

   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income)
   Assert.eq(true, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income"))
   Assert.eq(true, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Double fame income"))
   Assert.eq(false, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "dood"))
   Assert.eq(false, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income", "dood", "Double fame income"))
end

function test_Advice_remove()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   local fn = Calc.calc_fame_income

   Assert.is_truthy(Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income))
   Assert.is_truthy(Advice.remove("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Double fame income"))

   Assert.eq(false, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income"))
   Assert.eq(3050, Calc.calc_fame_income(player))
   Assert.eq(fn, Calc.calc_fame_income)
end

function test_Advice_remove_invalid()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   local fn = Calc.calc_fame_income

   Assert.is_falsy(Advice.remove("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Double fame income"))
   Assert.eq(fn, Calc.calc_fame_income)
end

function test_Advice_add__multi()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Assert.is_truthy(Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income))
   Assert.is_truthy(Advice.add("override", "mod.elona.api.Calc", "calc_fame_income", "Flat fame income", flat_fame_income))

   Assert.eq(9999, Calc.calc_fame_income(player))
end

function test_Advice_add__multi_2()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Assert.is_truthy(Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income))
   Assert.is_truthy(Advice.add("override", "mod.elona.api.Calc", "calc_fame_income", "Flat fame income", flat_fame_income))

   Assert.eq(9999, Calc.calc_fame_income(player))
end

function test_Advice_add__multi_priority()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Assert.is_truthy(Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income, { priority = 100000 }))
   Assert.is_truthy(Advice.add("override", "mod.elona.api.Calc", "calc_fame_income", "Flat fame income", flat_fame_income, { priority = 50000 }))

   Assert.eq(19998, Calc.calc_fame_income(player))
end
