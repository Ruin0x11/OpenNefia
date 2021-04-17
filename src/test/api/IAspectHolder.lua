local data = require("internal.data")
local AspectHolder_TestAspect = require("test.api.AspectHolder_TestAspect")
local AspectHolder_ITestAspect = require("test.api.AspectHolder_ITestAspect")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local IAspectHolder = require("api.IAspectHolder")

function test_IAspectHolder_normal_build()
   data:add {
      _type = "base.item",
      _id = "aspected",

      ext = {
         AspectHolder_ITestAspect
      }
   }

   local item = Item.create("@test@.aspected", nil, nil, {ownerless = true})

   Assert.eq(1, IAspectHolder.iter_aspects(item):length())

   local aspect = IAspectHolder.get_aspect(item, AspectHolder_ITestAspect)
   Assert.eq(true, class.is_an(AspectHolder_TestAspect, aspect))
   Assert.eq(0, aspect.foo)
end

function test_IAspectHolder_normal_build__params()
   data:add {
      _type = "base.item",
      _id = "aspected_with_params",

      ext = {
         [AspectHolder_ITestAspect] = {
            my_foo = 42
         }
      }
   }

   local item = Item.create("@test@.aspected_with_params", nil, nil, {ownerless = true})

   Assert.eq(1, IAspectHolder.iter_aspects(item):length())

   local aspect = IAspectHolder.get_aspect(item, AspectHolder_ITestAspect)
   Assert.eq(true, class.is_an(AspectHolder_TestAspect, aspect))
   Assert.eq(42, aspect.foo)
end
