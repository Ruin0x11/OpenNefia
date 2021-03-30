local InstancedMap = require("api.InstancedMap")
local TestUtil = require("api.test.TestUtil")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Effect = require("mod.elona.api.Effect")
local Assert = require("api.test.Assert")

function test_god_kumiromi_harvest_seeds()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.grass_rocks")
   local player = TestUtil.set_player(map)
   player.god = "elona.kumiromi"

   local corpse = Item.create("elona.corpse", 5, 5, {amount=5}, player)

   local items = player:iter_inventory()
   Assert.eq(1, items:length())

   Rand.set_seed(8)
   corpse.spoilage_date = 1
   Effect.spoil_items(map)

   items = player:iter_inventory()
   Assert.eq(2, items:length())
   local seed = items:nth(2)
   Assert.eq("elona.corpse", corpse._id)
   Assert.eq(1, corpse.amount)
   Assert.eq("elona.fruit_seed", seed._id)
   Assert.eq(4, seed.amount)
   Assert.eq(true, seed:has_category("elona.crop_seed"))
end
