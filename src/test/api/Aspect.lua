local Aspect = require("api.Aspect")
local AspectHolder_ITestAspect = require("test.api.AspectHolder_ITestAspect")
local AspectHolder_TestAspect = require("test.api.AspectHolder_TestAspect")
local AspectHolder_TestAspectModdable = require("test.api.AspectHolder_TestAspectModdable")
local Assert = require("api.test.Assert")

function test_Aspect_set_default_impl()
   local impl = Aspect.get_default_impl(AspectHolder_ITestAspect)
   Assert.eq(AspectHolder_TestAspect, impl)

   Aspect.set_default_impl(AspectHolder_ITestAspect, AspectHolder_TestAspectModdable)
   impl = Aspect.get_default_impl(AspectHolder_ITestAspect)
   Assert.eq(AspectHolder_TestAspectModdable, impl)
end
