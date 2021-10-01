local Assert = require("api.test.Assert")
local TestUtil = require("api.test.TestUtil")
local ItemFromCharaAspect = require("mod.elona.api.aspect.ItemFromCharaAspect")

function test_ItemFromCharaAspect_init()
   local item = TestUtil.stripped_item("elona.card")

   local params = { chara_id = "elona.putit" }
   local aspect = ItemFromCharaAspect:new(item, params)

   Assert.eq("elona.putit", aspect.chara_id)
   Assert.eq(nil, aspect.color)
   Assert.eq("elona.chara_race_slime", aspect.image)
   Assert.eq(nil, aspect.gender)

   params = {
      chara_id = "elona.putit",
      color = { 125, 125, 125 },
      image = "elona.item_putitoro",
      gender = "female"
   }
   aspect = ItemFromCharaAspect:new(item, params)

   Assert.eq("elona.putit", aspect.chara_id)
   Assert.same({ 125, 125, 125 }, aspect.color)
   Assert.eq("elona.item_putitoro", aspect.image)
   Assert.eq("female", aspect.gender)
end
