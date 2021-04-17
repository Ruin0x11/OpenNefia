local InstancedMap = require("api.InstancedMap")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local Weather = require("mod.elona.api.Weather")
local Effect = require("mod.elona.api.Effect")
local World = require("api.World")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local Enum = require("api.Enum")
local IItemFood = require("mod.elona.api.aspect.IItemFood")

function test_Effect_spoil_items()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.grass_rocks")

   local corpse = Item.create("elona.corpse", 5, 5, {}, map)
   corpse.spoilage_date = math.huge
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.no_matches("rotten ", corpse:build_name())

   Effect.spoil_items(map)
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.no_matches("rotten ", corpse:build_name())

   corpse:get_aspect(IItemFood).spoilage_date = 0
   Effect.spoil_items(map)
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.no_matches("rotten ", corpse:build_name())

   corpse:get_aspect(IItemFood).spoilage_date = -1
   Assert.matches("rotten ", corpse:build_name())

   corpse:get_aspect(IItemFood).spoilage_date = 1
   Effect.spoil_items(map)
   Assert.eq("elona.item_rotten_food", corpse.image)
   Assert.matches("rotten ", corpse:build_name())
   Assert.eq(-1, corpse:get_aspect(IItemFood).spoilage_date)
end

function test_Effect_spoil_items__jerky()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.dryground")

   local corpse = Item.create("elona.corpse", 5, 5, {}, map)
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.eq("elona.corpse", corpse._id)
   Assert.eq("elona.meat", corpse:calc_aspect_base(IItemFood, "food_type"))
   Assert.eq(0, corpse:calc_aspect_base(IItemFood, "food_quality"))

   Effect.spoil_items(map)
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.eq("elona.corpse", corpse._id)
   Assert.eq("elona.meat", corpse:calc_aspect_base(IItemFood, "food_type"))
   Assert.eq(0, corpse:calc_aspect_base(IItemFood, "food_quality"))

   corpse:get_aspect(IItemFood).spoilage_date = 1
   Weather.change_to("elona.rain")
   Effect.spoil_items(map)
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.eq("elona.corpse", corpse._id)
   Assert.eq("elona.meat", corpse:calc_aspect_base(IItemFood, "food_type"))
   Assert.eq(0, corpse:calc_aspect_base(IItemFood, "food_quality"))

   Weather.change_to("elona.sunny")
   Effect.spoil_items(map)
   Assert.eq("elona.item_jerky", corpse.image)
   Assert.eq("elona.jerky", corpse._id)
   Assert.eq(nil, corpse:calc_aspect_base(IItemFood, "food_type"))
   Assert.eq(5, corpse:calc_aspect_base(IItemFood, "food_quality"))
   Assert.gt(World.date_hours(), corpse:get_aspect(IItemFood).spoilage_date)

   corpse:get_aspect(IItemFood).spoilage_date = 1
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
   Assert.eq(nil, dagger:get_aspect_or_default(IItemFood).spoilage_date)

   Effect.spoil_items(map)
   Assert.eq("elona.item_dagger", dagger.image)
   Assert.eq("elona.dagger", dagger._id)
end

function test_Effect_spoil_items__own_state()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local corpse = Item.create("elona.corpse", 5, 5, {aspects={[IItemFood]={spoilage_date=1}}}, map)
   corpse.own_state = Enum.OwnState.NotOwned
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.no_matches("rotten ", corpse:build_name())

   Effect.spoil_items(map)
   Assert.eq("elona.item_corpse", corpse.image)
   Assert.no_matches("rotten ", corpse:build_name())

   corpse.own_state = Enum.OwnState.None
   Effect.spoil_items(map)
   Assert.eq("elona.item_rotten_food", corpse.image)
   Assert.matches("rotten ", corpse:build_name())
   Assert.eq(-1, corpse:calc_aspect_base(IItemFood, "spoilage_date"))
end
