local TestUtil = require("api.test.TestUtil")
local SaveFs = require("api.SaveFs")
local Assert = require("api.test.Assert")

function test_serial_nested_map_object_reference()
   local a = TestUtil.stripped_chara("elona.putit")
   local b = TestUtil.stripped_chara("elona.putit")
   a.b = b
   b.a = a
   local t = { a }

   Assert.eq(t[1], t[1].b.a) -- by reference

   local t2 = SaveFs.deserialize(SaveFs.serialize(t))
   Assert.eq(t2[1], t2[1].b.a)
end
