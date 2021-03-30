local fs = require("util.fs")
local Assert = require("api.test.Assert")

function test_fs_sanitize__reserved()
   Assert.eq("Zeome", fs.sanitize("<Zeome>"))
   Assert.eq("_Zeome_", fs.sanitize("<Zeome>", "_"))
   Assert.eq("", fs.sanitize("\"\""))
   Assert.eq("", fs.sanitize(".   "))
end

function test_fs_sanitize__windows()
   Assert.eq("", fs.sanitize("con"))
   Assert.eq("", fs.sanitize("COM1"))
   Assert.eq("", fs.sanitize("aux.txt"))
   Assert.eq("dood", fs.sanitize("dood."))
end

function test_fs_sanitize__length()
   Assert.eq(255, string.len(fs.sanitize(string.rep("a", 1000))))
end
