local Chara = require("api.Chara")
local Assert = require("api.test.Assert")

function test_object__set_reserved_field()
   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})

   Assert.throws_error(function() chara._id = "dood" end)
   Assert.throws_error(function() chara._type = "dood" end)
   Assert.throws_error(function() chara.__mt = "dood" end)
   Assert.throws_error(function() chara.__iface = "dood" end)
   Assert.throws_error(function() chara.proto = "dood" end)
end
