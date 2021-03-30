local Assert = require("api.test.Assert")
local Color = require("mod.extlibs.api.Color")

function test_Color_to_number()
   Assert.eq(0, Color.to_number(0, 0, 0, 0))
   Assert.eq(255, Color.to_number(0, 0, 0, 255))
   Assert.eq(65280, Color.to_number(0, 0, 255, 0))
   Assert.eq(16711680, Color.to_number(0, 255, 0, 0))
   Assert.eq(4278190080, Color.to_number(255, 0, 0, 0))
   Assert.eq(4294967295, Color.to_number(255, 255, 255, 255))
   Assert.eq(4294967295, Color.to_number(9999, 9999, 9999, 9999))
   Assert.eq(0, Color.to_number(-9999, -9999, -9999, -9999))
end

function test_Color_from_number()
   Assert.same({ 0, 0, 0, 0 }, { Color.from_number(0) })
   Assert.same({ 0, 0, 0, 255 }, { Color.from_number(255) })
   Assert.same({ 0, 0, 255, 0 }, { Color.from_number(65280) })
   Assert.same({ 0, 255, 0, 0 }, { Color.from_number(16711680) })
   Assert.same({ 255, 0, 0, 0 }, { Color.from_number(4278190080) })
   Assert.same({ 255, 255, 255, 255 }, { Color.from_number(4294967295) })
   Assert.same({ 255, 255, 255, 255 }, { Color.from_number(99999999999) })
   Assert.same({ 0, 0, 0, 0 }, { Color.from_number(-99999999999) })
end
