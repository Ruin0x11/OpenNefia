local Assert = require("api.test.Assert")
local Item = require("api.Item")
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")

function test_data_item_card_events()
   local item = Item.create("elona.card", nil, nil, {ownerless = true, aspects={[IItemFromChara] = { chara_id = "elona.putit" }}})

   Assert.is_truthy(item:get_drawable("elona.card"))
end

function test_data_item_figurine_events()
   local item = Item.create("elona.figurine", nil, nil, {ownerless = true, aspects={[IItemFromChara] = { chara_id = "elona.putit" }}})

   Assert.is_truthy(item:get_drawable("elona.figurine"))
end
