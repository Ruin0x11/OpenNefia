local data = require("internal.data")
local AspectHolder_ITestAspect = require("test.api.AspectHolder_ITestAspect")
local AspectHolder_TestAspect = require("test.api.AspectHolder_TestAspect")
local AspectHolder_TestAspectModdable = require("test.api.AspectHolder_TestAspectModdable")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local IAspectHolder = require("api.IAspectHolder")

function test_IAspectHolder_normal_build()
   data:add {
      _type = "base.item",
      _id = "aspected",

      _ext = {
         AspectHolder_ITestAspect
      }
   }

   local item = Item.create("@test@.aspected", nil, nil, {ownerless = true})

   Assert.eq(1, IAspectHolder.iter_aspects(item):length())
   Assert.eq(nil, item._ext)

   local aspect = IAspectHolder.get_aspect(item, AspectHolder_ITestAspect)
   Assert.eq(true, class.is_an(AspectHolder_TestAspect, aspect))
   Assert.eq(0, aspect.foo)
end

function test_IAspectHolder_normal_build__params()
   data:add {
      _type = "base.item",
      _id = "aspected_with_params",

      _ext = {
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

function test_IAspectHolder_normal_build__impl()
   data:add {
      _type = "base.item",
      _id = "aspected_with_impl",

      _ext = {
         [AspectHolder_ITestAspect] = {
            _impl = AspectHolder_TestAspectModdable,
            my_foo = 42
         }
      }
   }

   local item = Item.create("@test@.aspected_with_impl", nil, nil, {ownerless = true})

   Assert.eq(1, IAspectHolder.iter_aspects(item):length())

   local aspect = IAspectHolder.get_aspect(item, AspectHolder_ITestAspect)
   Assert.eq(true, class.is_an(AspectHolder_TestAspectModdable, aspect))
   Assert.eq(42, aspect.foo)
   Assert.eq(4200, aspect:calc(item, "foo"))
end

function test_IAspectHolder_calc()
   local item = Item.create("@test@.aspected_with_params", nil, nil, {ownerless = true})

   local aspect = IAspectHolder.get_aspect(item, AspectHolder_ITestAspect)

   Assert.eq(42, aspect.foo)
   Assert.eq(42, aspect:calc(item, "foo"))

   aspect:mod(item, "foo", 10, "add")

   Assert.eq(42, aspect.foo)
   Assert.eq(52, aspect:calc(item, "foo"))

   item:refresh()

   Assert.eq(42, aspect.foo)
   Assert.eq(42, aspect:calc(item, "foo"))
end

function test_IAspectHolder_calc__custom_moddable_impl()
   local item = Item.create("@test@.aspected_with_params", nil, nil, {ownerless = true})

   local aspect = AspectHolder_TestAspectModdable:new(item, { my_foo = 42 })
   item:set_aspect(AspectHolder_ITestAspect, aspect)

   Assert.eq(42, aspect.foo)
   Assert.eq(4200, aspect:calc(item, "foo"))

   aspect:mod(item, "foo", 10, "add")

   Assert.eq(42, aspect.foo)
   Assert.eq(94, aspect.temp["foo"])
   Assert.eq(9400, aspect:calc(item, "foo"))

   item:refresh()

   Assert.eq(42, aspect.foo)
   Assert.eq(4200, aspect:calc(item, "foo"))
end

function test_IAspectHolder_calc_aspect()
   local item = Item.create("@test@.aspected_with_params", nil, nil, {ownerless = true})

   Assert.eq(42, item:calc_aspect(AspectHolder_ITestAspect, "foo"))

   item:mod_aspect(AspectHolder_ITestAspect, "foo", 10, "add")

   Assert.eq(52, item:calc_aspect(AspectHolder_ITestAspect, "foo"))

   item:refresh()

   Assert.eq(42, item:calc_aspect(AspectHolder_ITestAspect, "foo"))
end

function test_IAspectHolder_get_aspect_proto()
   local item = Item.create("@test@.aspected", nil, nil, {ownerless = true})

   local proto = item:get_aspect_proto(AspectHolder_ITestAspect)
   Assert.same({}, proto)
end

function test_IAspectHolder_get_aspect_proto__params()
   local item = Item.create("@test@.aspected_with_params", nil, nil, {ownerless = true})

   local proto = item:get_aspect_proto(AspectHolder_ITestAspect)
   Assert.is_truthy(proto)
   Assert.eq(42, proto.my_foo)
end
