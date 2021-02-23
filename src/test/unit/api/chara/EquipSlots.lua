local EquipSlots = require("api.EquipSlots")
local Assert = require("api.test.Assert")
local Item = require("api.Item")

function test_EquipSlots_iter_all_body_parts__blocked()
   local equip = EquipSlots:new { "elona.hand", "elona.neck" }

   Assert.eq(2, equip:iter_all_body_parts():length())
   Assert.eq(0, equip:iter_equipped_body_parts():length())

   local item = Item.create("elona.dagger", nil, nil, {ownerless=true})
   Assert.is_truthy(equip:equip(item))

   Assert.eq(2, equip:iter_all_body_parts():length())
   Assert.eq(1, equip:iter_equipped_body_parts():length())

   equip:set_body_part_blocked("elona.hand", true)

   Assert.eq(1, equip:iter_all_body_parts():length())
   Assert.eq(0, equip:iter_equipped_body_parts():length())

   item = Item.create("elona.engagement_amulet", nil, nil, {ownerless=true})
   Assert.is_truthy(equip:equip(item))

   Assert.eq(1, equip:iter_all_body_parts():length())
   Assert.eq(1, equip:iter_equipped_body_parts():length())

   equip:set_body_part_blocked("elona.hand", false)

   Assert.eq(2, equip:iter_all_body_parts():length())
   Assert.eq(2, equip:iter_equipped_body_parts():length())
end
