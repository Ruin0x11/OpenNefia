local Chara = require("api.Chara")
local Item = require("api.Item")
local Test = require("api.test.Test")

function test_map_object_clone_nested_location()
   local chara = Chara.create("elona.putit", nil, nil, { ownerless = true })
   local equipment = Item.create("elona.arrow", nil, nil, {}, chara)
   assert(chara:equip_item(equipment))
   local equipped = chara:iter_equipment():nth(1)
   local on_body_part = chara:iter_body_parts():nth(1).equipped

   Test.assert_eq(equipped.uid, on_body_part.uid)
   Test.assert_eq(equipped, on_body_part)

   local clone = chara:clone()
   equipped = clone:iter_equipment():nth(1)
   on_body_part = clone:iter_body_parts():nth(1).equipped

   Test.assert_eq(equipped.uid, on_body_part.uid)
   Test.assert_eq(equipped, on_body_part)
end
