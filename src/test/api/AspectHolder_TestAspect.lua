local AspectHolder_ITestAspect = require("test.api.AspectHolder_ITestAspect")

local AspectHolder_TestAspect = class.class("AspectHolder_TestAspect", AspectHolder_ITestAspect)

function AspectHolder_TestAspect:init(target, params)
   self.foo = params.my_foo or 0
end

return AspectHolder_TestAspect
