local Item = require("api.Item")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")
local Assert = require("api.test.Assert")

function test_IItemEquipment_init()
   local item = Item.create("elona.dragon_slayer", nil, nil, {ownerless=true})
   local equip = item:get_aspect(IItemEquipment)

   Assert.is_truthy(equip)
   Assert.eq(-42, equip.dv)
   Assert.eq(30, equip.pv)
   Assert.eq(-25, equip.hit_bonus)
   Assert.eq(20, equip.damage_bonus)
end
