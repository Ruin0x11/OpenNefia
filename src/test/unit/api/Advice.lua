local Advice = require("api.Advice")
local Calc = require("mod.elona.api.Calc")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local test_util = require("test.lib.test_util")
local Advice_TestModule = require("test.unit.api.Advice_TestModule")

local function double_fame_income(orig_fn, chara)
   return orig_fn(chara) * 2
end

local function additional_fame_income(orig_fn, chara)
   return orig_fn(chara) + 5000
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

   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income)
   Assert.eq(6100, Calc.calc_fame_income(player))
   Assert.not_eq(fn, Calc.calc_fame_income)
end

function test_Advice_add__disabled()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   local fn = Calc.calc_fame_income

   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income, { enabled = false })
   Assert.eq(3050, Calc.calc_fame_income(player))
   Assert.eq(fn, Calc.calc_fame_income)
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

   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income)
   Advice.remove("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Double fame income")

   Assert.eq(false, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income"))
   Assert.eq(3050, Calc.calc_fame_income(player))
   Assert.eq(fn, Calc.calc_fame_income)
end

function test_Advice_add__multi()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income)
   Advice.add("override", "mod.elona.api.Calc", "calc_fame_income", "Flat fame income", flat_fame_income)

   Assert.eq(9999, Calc.calc_fame_income(player))
end

function test_Advice_add__multi_2()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income)
   Advice.add("override", "mod.elona.api.Calc", "calc_fame_income", "Flat fame income", flat_fame_income)

   Assert.eq(9999, Calc.calc_fame_income(player))
end

function test_Advice_add__multi_priority()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income, { priority = 100000 })
   Advice.add("override", "mod.elona.api.Calc", "calc_fame_income", "Flat fame income", flat_fame_income, { priority = 50000 })

   Assert.eq(19998, Calc.calc_fame_income(player))
end

function test_Advice_set_enabled()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income, { priority = 100000 })
   Advice.add("override", "mod.elona.api.Calc", "calc_fame_income", "Flat fame income", flat_fame_income, { priority = 50000 })
   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Additional fame income", additional_fame_income, { priority = 200000 })
   Assert.eq(24998, Calc.calc_fame_income(player))

   Advice.set_enabled("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Flat fame income", false)
   Assert.eq(11100, Calc.calc_fame_income(player))

   Advice.set_enabled("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Additional fame income", false)
   Assert.eq(6100, Calc.calc_fame_income(player))

   Advice.set_enabled("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Double fame income", false)
   Assert.eq(3050, Calc.calc_fame_income(player))
   Assert.eq(true, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income"))
   Assert.eq(true, Advice.is_advised("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Double fame income"))

   Advice.set_enabled("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Flat fame income", true)
   Assert.eq(9999, Calc.calc_fame_income(player))

   Advice.set_enabled("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Additional fame income", true)
   Assert.eq(14999, Calc.calc_fame_income(player))

   Advice.set_enabled("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Double fame income", true)
   Assert.eq(24998, Calc.calc_fame_income(player))
end

function test_Advice_set_enabled__validation()
   Assert.throws_error(function() Advice.set_enabled("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Flat fame income", false) end,
      "Advice from mod '@test@' with identifier 'Flat fame income' does not exist.")
end

function test_Advice_add__multi_remove()
   local player = Chara.create("elona.putit", nil, nil, {ownerless=true})
   player.fame = 30000

   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income, { priority = 100000 })
   Advice.add("override", "mod.elona.api.Calc", "calc_fame_income", "Flat fame income", flat_fame_income, { priority = 50000 })
   Advice.remove("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Flat fame income")

   Assert.eq(6100, Calc.calc_fame_income(player))
end

function test_Advice_add__validation()
   Assert.throws_error(function() Advice.add("dood", "mod.elona.api.Calc", "calc_fame_income", "Flat fame income", flat_fame_income, { priority = 50000 }) end,
      "Invalid advice location 'dood'")
   Assert.throws_error(function() Advice.add("override", "dood", "calc_fame_income", "Flat fame income", flat_fame_income) end,
      "The module at require path 'dood' was not defined publicly.")
   Assert.throws_error(function() Advice.add("override", "mod.elona.api.Calc", "dood", "Flat fame income", flat_fame_income) end,
      "The thing at 'mod.elona.api.Calc:dood' was not a function")
end

function test_Advice_remove__validation()
   Assert.throws_error(function() Advice.remove("mod.elona.api.Calc", "calc_fame_income", test_util.TEST_MOD_ID, "Flat fame income") end,
      "Advice from mod '@test@' with identifier 'Flat fame income' does not exist.")
   Assert.throws_error(function() Advice.remove("dood", "calc_fame_income", "Flat fame income", flat_fame_income) end,
      "The module at require path 'dood' was not defined publicly.")
   Assert.throws_error(function() Advice.remove("mod.elona.api.Calc", "dood", "Flat fame income", flat_fame_income) end,
      "The thing at 'mod.elona.api.Calc:dood' was not a function")
end

function test_Advice_add__duplicate()
   Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income)
   Assert.throws_error(function() Advice.add("around", "mod.elona.api.Calc", "calc_fame_income", "Double fame income", double_fame_income) end,
      "Advice already exists for mod '@test@' and identifier 'Double fame income'.")
end

function test_Advice__locations_before()
   local arg = { called = false }

   local function before(arg)
      Assert.eq(false, arg.called)
      return "dood", 100
   end
   Advice.add("before", "test.unit.api.Advice_TestModule", "test", "Test before", before)

   local result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("ok", result1)
   Assert.eq(42, result2)
   Assert.eq(true, arg.called)
end

function test_Advice__locations_after()
   local arg = { called = false }

   local function after(arg)
      Assert.eq(true, arg.called)
      return "dood", 100
   end
   Advice.add("after", "test.unit.api.Advice_TestModule", "test", "Test after", after)

   local result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("ok", result1)
   Assert.eq(42, result2)
   Assert.eq(true, arg.called)
end

function test_Advice__locations_around()
   local arg = { called = false }

   local function around(old_fn, arg)
      Assert.eq(false, arg.called)
      old_fn(arg)
      Assert.eq(true, arg.called)
      return "dood", 100
   end
   Advice.add("around", "test.unit.api.Advice_TestModule", "test", "Test around", around)

   local result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("dood", result1)
   Assert.eq(100, result2)
   Assert.eq(true, arg.called)
end

function test_Advice__locations_override()
   local arg = { called = false }

   local function override(arg)
      Assert.eq(false, arg.called)
      return "dood", 100
   end
   Advice.add("override", "test.unit.api.Advice_TestModule", "test", "Test override", override)

   local result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("dood", result1)
   Assert.eq(100, result2)
   Assert.eq(false, arg.called)
end

function test_Advice__locations_before_while()
   local arg = { called = false }

   local do_return

   local function before_while(arg)
      Assert.eq(false, arg.called)
      return do_return
   end
   Advice.add("before_while", "test.unit.api.Advice_TestModule", "test", "Test before while", before_while)

   do_return = false
   local result1, result2 = Advice_TestModule.test(arg)

   Assert.eq(nil, result1)
   Assert.eq(nil, result2)
   Assert.eq(false, arg.called)

   arg = { called = false }
   do_return = true
   result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("ok", result1)
   Assert.eq(42, result2)
   Assert.eq(true, arg.called)
end

function test_Advice__locations_before_until()
   local arg = { called = false }

   local do_return

   local function before_until(arg)
      Assert.eq(false, arg.called)
      if do_return then
         return "dood", 100
      end
   end
   Advice.add("before_until", "test.unit.api.Advice_TestModule", "test", "Test before until", before_until)

   do_return = false
   local result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("ok", result1)
   Assert.eq(42, result2)
   Assert.eq(true, arg.called)

   arg = { called = false }
   do_return = true
   result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("dood", result1)
   Assert.eq(100, result2)
   Assert.eq(false, arg.called)
end

function test_Advice__locations_after_while()
   local arg = { called = false }

   local called
   local function after_while(arg)
      called = true
      Assert.eq(true, arg.called)
      return "dood", 100
   end
   Advice.add("after_while", "test.unit.api.Advice_TestModule", "test", "Test after while", after_while)

   called = false
   local result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("dood", result1)
   Assert.eq(100, result2)
   Assert.eq(true, arg.called)
   Assert.eq(true, called)

   arg = { called = false }
   called = false
   result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("dood", result1)
   Assert.eq(100, result2)
   Assert.eq(true, arg.called)
   Assert.eq(true, called)
end

function test_Advice__locations_after_while_false()
   local arg = { called = false }

   local called
   local function after_while(arg)
      called = true
      return "dood", 100
   end
   Advice.add("after_while", "test.unit.api.Advice_TestModule", "test_false", "Test after while (false)", after_while)

   called = false
   local result1, result2 = Advice_TestModule.test_false(arg)

   Assert.eq(nil, result1)
   Assert.eq(nil, result2)
   Assert.eq(true, arg.called)
   Assert.eq(false, called)
end

function test_Advice__locations_after_until()
   local arg = { called = false }

   local called
   local function after_until(arg)
      called = true
      return "dood", 100
   end
   Advice.add("after_until", "test.unit.api.Advice_TestModule", "test", "Test after until", after_until)

   called = false
   local result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("ok", result1)
   Assert.eq(42, result2)
   Assert.eq(true, arg.called)
   Assert.eq(false, called)

   arg = { called = false }
   called = false
   result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("ok", result1)
   Assert.eq(42, result2)
   Assert.eq(true, arg.called)
   Assert.eq(false, called)
end

function test_Advice__locations_after_until_false()
   local arg = { called = false }

   local called
   local function after_until(arg)
      called = true
      return "dood", 100
   end
   Advice.add("after_until", "test.unit.api.Advice_TestModule", "test_false", "Test after until (false)", after_until)

   called = false
   local result1, result2 = Advice_TestModule.test_false(arg)

   Assert.eq("dood", result1)
   Assert.eq(100, result2)
   Assert.eq(true, arg.called)
   Assert.eq(true, called)
end

function test_Advice__locations_filter_args()
   local arg = { called = false, extra = 0 }

   local called
   local function filter_args(arg1, arg2)
      called = true
      Assert.eq(5, arg2)
      arg1.extra = 42
      return arg1, 100
   end
   Advice.add("filter_args", "test.unit.api.Advice_TestModule", "test_args", "Test filter args", filter_args)

   called = false
   local result1, result2 = Advice_TestModule.test_args(arg, 5)

   Assert.eq("ok", result1)
   Assert.eq(142, result2)
   Assert.eq(true, arg.called)
   Assert.eq(42, arg.extra)
   Assert.eq(true, called)
end

function test_Advice__locations_filter_return()
   local arg = { called = false, extra = 0 }

   local called
   local function filter_return(result1, result2)
      called = true
      Assert.eq("ok", result1)
      Assert.eq(42, result2)
      return "dood", 100
   end
   Advice.add("filter_return", "test.unit.api.Advice_TestModule", "test", "Test filter return", filter_return)

   called = false
   local result1, result2 = Advice_TestModule.test(arg)

   Assert.eq("dood", result1)
   Assert.eq(100, result2)
   Assert.eq(true, arg.called)
   Assert.eq(true, called)
end
