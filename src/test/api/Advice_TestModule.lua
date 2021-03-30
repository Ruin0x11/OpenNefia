local Advice_TestModule = {}

function Advice_TestModule.test(arg)
   arg.called = true
   return "ok", 42
end

function Advice_TestModule.test_false(arg)
   arg.called = true
   return false
end

function Advice_TestModule.test_args(arg1, arg2)
   arg1.called = true
   return "ok", arg1.extra + arg2
end

return Advice_TestModule
