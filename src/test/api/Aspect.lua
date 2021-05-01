local Aspect = require("api.Aspect")
local AspectHolder_ITestAspect = require("test.api.AspectHolder_ITestAspect")
local AspectHolder_TestAspect = require("test.api.AspectHolder_TestAspect")
local AspectHolder_TestAspectModdable = require("test.api.AspectHolder_TestAspectModdable")
local Assert = require("api.test.Assert")
local IItemMonsterBall = require("mod.elona.api.aspect.IItemMonsterBall")
local Item = require("api.Item")

function test_Aspect_set_default_impl()
   local impl = Aspect.get_default_impl(AspectHolder_ITestAspect)
   Assert.eq(AspectHolder_TestAspect, impl)

   Aspect.set_default_impl(AspectHolder_ITestAspect, AspectHolder_TestAspectModdable)
   impl = Aspect.get_default_impl(AspectHolder_ITestAspect)
   Assert.eq(AspectHolder_TestAspectModdable, impl)
end

function test_Aspect_set_params()
   local aspects = {
      [IItemMonsterBall] = {
         max_level = 5
      }
   }
   local monster_ball = Item.create("elona.monster_ball", nil, nil, {ownerless = true, aspects = aspects})

   Assert.eq(5, monster_ball:calc_aspect(IItemMonsterBall, "max_level"))
end
