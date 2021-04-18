local TestUtil = require("api.test.TestUtil")
local Assert = require("api.test.Assert")
local Log = require("api.Log")

function test_hotload_hotload()
   Log.set_level("debug")
   local result = TestUtil.hotload_code("mod.@test@.api.Test", TestUtil.TEST_MOD_ID, [[
local Test = {}

return Test
]])

   Assert.eq(0, table.count(result.module))
   Assert.eq("mod.@test@.api.Test", result.require_path)

   result = TestUtil.hotload_code("mod.@test@.api.Test", TestUtil.TEST_MOD_ID, [[
local Test = {}

function Test.dood()
end

return Test
]])

   Assert.eq(1, table.count(result.module))
   Assert.eq("function", type(result.module.dood))

   result = TestUtil.hotload_code("mod.@test@.api.Test", TestUtil.TEST_MOD_ID, [[
local Test = {}

return Test
]])

   Assert.eq(0, table.count(result.module))
end
