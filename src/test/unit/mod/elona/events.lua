local Chara = require("api.Chara")
local Assert = require("api.test.Assert")

function test_charagen_default_race_image_gendered()
   local chara = Chara.create("elona.shopkeeper", nil, nil, {ownerless=true})
   Assert.not_eq("base.default", chara.image)
end

function test_charagen_default_race_image()
   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})
   Assert.eq("elona.chara_race_slime", chara.image)
end

function test_charagen_default_race_image_override()
   local chara = Chara.create("elona.xabi", nil, nil, {ownerless=true})
   Assert.eq("elona.chara_xabi", chara.image)
end
