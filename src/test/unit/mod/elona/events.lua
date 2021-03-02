local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local Rand = require("api.Rand")
local InstancedMap = require("api.InstancedMap")
local I18N = require("api.I18N")

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

function test_charagen_shade()
   Rand.set_seed(5)
   local map = InstancedMap:new(10, 10)
   local chara = Chara.create("elona.shade", 4, 5, {level = 20}, map)

   Assert.not_eq("elona.shade", chara._id)
   Assert.eq(I18N.get("chara.job.shade"), chara.name)
   Assert.eq(37, chara.level)
   Assert.eq(true, map:has_object(chara))
   Assert.eq(4, chara.x)
   Assert.eq(5, chara.y)
end
