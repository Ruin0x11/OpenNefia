local Item = require("api.Item")
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")
local IItemFood = require("mod.elona.api.aspect.IItemFood")
local Assert = require("api.test.Assert")

function test_Item_create__aspect_params()
   local params = {
      [IItemFromChara] = {
         chara_id = "elona.little_sister"
      },
      [IItemFood] = {
         food_quality = 8
      }
   }

   local corpse = Item.create("elona.corpse", nil, nil, {ownerless = true, amount = 3, aspects = params})

   Assert.eq("elona.little_sister", corpse:get_aspect(IItemFromChara).chara_id)
   Assert.eq(8, corpse:get_aspect(IItemFood).food_quality)
end
