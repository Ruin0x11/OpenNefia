local Item = require("api.Item")
local IItemBlacksmithHammer = require("mod.smithing.api.aspect.IItemBlacksmithHammer")
local Assert = require("api.test.Assert")

function test_ItemBlacksmithHammerAspect_init()
   local hammer = Item.create("smithing.blacksmith_hammer", nil, nil, {ownerless=true})

   Assert.eq(1, hammer:calc_aspect(IItemBlacksmithHammer, "hammer_level"))
   Assert.eq(0, hammer:calc_aspect(IItemBlacksmithHammer, "hammer_experience"))
   Assert.eq(0, hammer:calc_aspect(IItemBlacksmithHammer, "total_uses"))

   Assert.eq(true, hammer:has_event_handler("base.on_item_build_description"))
end

function test_ItemBlacksmithHammerAspect_calc_equipment_upgrade_power()
   local hammer = Item.create("smithing.blacksmith_hammer", nil, nil, {ownerless=true})
   local aspect = hammer:get_aspect(IItemBlacksmithHammer)

   Assert.eq(0, aspect:calc_equipment_upgrade_power(hammer))

   aspect.hammer_level = 500

   Assert.eq(225, aspect:calc_equipment_upgrade_power(hammer))

   aspect:mod(hammer, "hammer_level", 2200, "set")

   Assert.eq(950, aspect:calc_equipment_upgrade_power(hammer))

   aspect:on_refresh()

   Assert.eq(225, aspect:calc_equipment_upgrade_power(hammer))
end

function test_ItemBlacksmithHammerAspect_calc_item_generation_seed()
   local hammer = Item.create("smithing.blacksmith_hammer", nil, nil, {ownerless=true})
   local aspect = hammer:get_aspect(IItemBlacksmithHammer)

   Assert.eq(1000000, aspect:calc_item_generation_seed(hammer))

   aspect.hammer_level = 500

   Assert.eq(500000000, aspect:calc_item_generation_seed(hammer))

   aspect.hammer_experience = 1234

   Assert.eq(500001234, aspect:calc_item_generation_seed(hammer))
end
