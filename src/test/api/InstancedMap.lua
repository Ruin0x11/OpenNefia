local InstancedMap = require("api.InstancedMap")
local Assert = require("api.test.Assert")
local AspectHolder_ITestAspect = require("test.api.AspectHolder_ITestAspect")

function test_InstancedMap_aspects()
   local map = InstancedMap:new(10, 10)

   Assert.eq(nil, map:get_aspect(AspectHolder_ITestAspect))

   local aspect = map:get_aspect_or_default(AspectHolder_ITestAspect, "no_set")
   Assert.eq(0, aspect.foo)
   Assert.eq(nil, map:get_aspect(AspectHolder_ITestAspect))

   local aspect = map:get_aspect_or_default(AspectHolder_ITestAspect)
   Assert.eq(0, aspect.foo)
   Assert.eq(aspect, map:get_aspect(AspectHolder_ITestAspect))
   Assert.eq(0, map:calc_aspect(AspectHolder_ITestAspect, "foo"))

   aspect.foo = 1
   Assert.eq(1, map:calc_aspect(AspectHolder_ITestAspect, "foo"))
end
