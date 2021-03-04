local InstancedMap = require("api.InstancedMap")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local Weather = require("mod.elona.api.Weather")
local Effect = require("mod.elona.api.Effect")
local World = require("api.World")
local ItemMaterial = require("mod.elona.api.ItemMaterial")

function test_Effect_spoil_items()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.grass_rocks")

   local corpse = Item.create("elona.corpse", 5, 5, {}, map)
   corpse.spoilage_date = -1
   Assert.eq("elona.item_corpse", corpse.image)

   Effect.spoil_items(map)
   Assert.eq("elona.item_corpse", corpse.image)

   corpse.spoilage_date = 0
   Effect.spoil_items(map)
   Assert.eq("elona.item_corpse", corpse.image)

   corpse.spoilage_date = 1
   Effect.spoil_items(map)
   Assert.eq("elona.item_rotten_food", corpse.image)
end

function test_Effect_spoil_items__jerky()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.dryground")

   local corpse = Item.create("elona.corpse", 5, 5, {}, map)
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.eq("elona.corpse", corpse._id)
   Assert.eq("elona.meat", corpse.params.food_type)
   Assert.eq(0, corpse.params.food_quality)

   Effect.spoil_items(map)
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.eq("elona.corpse", corpse._id)
   Assert.eq("elona.meat", corpse.params.food_type)
   Assert.eq(0, corpse.params.food_quality)

   corpse.spoilage_date = 1
   Weather.change_to("elona.rain")
   Effect.spoil_items(map)
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.eq("elona.corpse", corpse._id)
   Assert.eq("elona.meat", corpse.params.food_type)
   Assert.eq(0, corpse.params.food_quality)

   Weather.change_to("elona.sunny")
   Effect.spoil_items(map)
   Assert.eq("elona.item_jerky", corpse.image)
   Assert.eq("elona.jerky", corpse._id)
   Assert.eq(nil, corpse.params.food_type)
   Assert.eq(5, corpse.params.food_quality)
   Assert.gt(World.date_hours(), corpse.spoilage_date)

   corpse.spoilage_date = 1
   Effect.spoil_items(map)
   Assert.eq("elona.item_rotten_food", corpse.image)
   Assert.eq("elona.jerky", corpse._id)
end

function test_Effect_spoil_items__raw()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local dagger = Item.create("elona.dagger", 5, 5, {}, map)
   ItemMaterial.change_item_material(dagger, "elona.fresh")
   Assert.eq("elona.item_dagger", dagger.image)
   Assert.eq("elona.dagger", dagger._id)
   Assert.eq(nil, dagger.spoilage_date)

   Effect.spoil_items(map)
   Assert.eq("elona.item_dagger", dagger.image)
   Assert.eq("elona.dagger", dagger._id)
end
