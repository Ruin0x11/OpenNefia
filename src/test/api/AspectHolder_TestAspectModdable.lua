local AspectHolder_ITestAspect = require("test.api.AspectHolder_ITestAspect")
local IAspectModdable = require("api.IAspectModdable")

local AspectHolder_TestAspectModdable = class.class("TestAspectModdable", AspectHolder_ITestAspect)

function AspectHolder_TestAspectModdable:init(target, params)
   self.foo = params.my_foo or 0
end

function AspectHolder_TestAspectModdable:calc(target, prop)
   local v = IAspectModdable.calc(self, target, "foo")

   if prop == "foo" then
      return v * 100
   end

   return v
end

function AspectHolder_TestAspectModdable:mod(target, prop, v, params)
   if prop == "foo" then
      v = v + 42
   end

   return IAspectModdable.mod(self, target, prop, v, params)
end

return AspectHolder_TestAspectModdable
