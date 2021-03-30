local Prompt = require("api.gui.Prompt")
local Assert = require("api.test.Assert")

function test_Prompt_init__validates_indices()
   Assert.is_truthy(Prompt:new { "a", "b", "c" })
   Assert.is_truthy(Prompt:new { 1, 2, 3 })
   Assert.is_truthy(Prompt:new { function() end, true, "foo" })
   Assert.is_truthy(Prompt:new { { text = "a" }, { text = "b" }, { text = "c" } })
   Assert.is_truthy(Prompt:new { { text = "a", index = 1 }, { text = "b", index = 2 }} )
   Assert.is_truthy(Prompt:new { { text = "a", index = 2 }, { text = "b", index = 1 }} )

   Assert.throws_error(function() Prompt:new { { text = "a", index = 1 }, { text = "b", index = 1 }} end)
   Assert.throws_error(function() Prompt:new { { text = "a", index = 1 }, { text = "b", index = 2.5 }} end)
   Assert.throws_error(function() Prompt:new { "a", { text = "b", index = 1 }} end)
end
