local IAspect = require("api.IAspect")

local AspectHolder_ITestAspect = class.interface("ITestAspect", { foo = "number", }, { IAspect })

AspectHolder_ITestAspect.default_impl = "test.api.AspectHolder_TestAspect"

return AspectHolder_ITestAspect
