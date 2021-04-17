local Item = require("api.Item")
local Assert = require("api.test.Assert")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")

function test_aspect_on_use()
   local seed = Item.create("elona.unknown_seed", nil, nil, {ownerless=true})

   Assert.eq(1, seed:iter_aspects(IItemUseable):length())
   Assert.eq(true, seed:calc("can_use"))
end
