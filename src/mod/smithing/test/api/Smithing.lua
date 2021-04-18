local Smithing = require("mod.smithing.api.Smithing")
local Item = require("api.Item")
local IItemBlacksmithHammer = require("mod.smithing.api.aspect.IItemBlacksmithHammer")
local Assert = require("api.test.Assert")

function test_Smithing_can_smith_item__hammer()
   local hammer = Item.create("smithing.blacksmith_hammer", nil, nil, {ownerless=true})

   Assert.eq(false, hammer:get_aspect(IItemBlacksmithHammer):can_upgrade(hammer))
   Assert.eq(false, Smithing.can_smith_item(hammer, hammer, {}))

   hammer:get_aspect(IItemBlacksmithHammer).hammer_level = 2001

   Assert.eq(true, hammer:get_aspect(IItemBlacksmithHammer):can_upgrade(hammer))
   Assert.eq(true, Smithing.can_smith_item(hammer, hammer, {}))
end
