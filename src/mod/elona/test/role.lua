local ShopInventory = require("mod.elona.api.ShopInventory")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")
local Item = require("api.Item")
local test_util = require("api.test.test_util")

function test_wandering_merchant_trunk()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   test_util.set_player(map, 2, 2)

   local merchant = Chara.create("elona.shopkeeper", 4, 5, {}, map)
   merchant:add_role("elona.shopkeeper", { inventory_id = "elona.wandering_merchant" })
   merchant.shop_rank = 1

   Assert.eq(map, merchant:current_map())
   Assert.eq(nil, merchant.shop_inventory)
   local items = Item.at(4, 5, map)
   Assert.eq(0, items:length())

   ShopInventory.refresh_shop(merchant)
   Assert.is_truthy(merchant.shop_inventory)
   local item_count = merchant.shop_inventory:iter():length()
   Assert.gt(0, item_count)

   merchant:damage_hp(merchant:calc("max_hp")+1)

   Assert.eq(0, merchant.shop_inventory:iter():length())
   local trunk = Item.at(4, 5, map):filter(function(i) return i._id == "elona.shopkeepers_trunk" end):nth(1)
   Assert.is_truthy(trunk)
   Assert.eq(item_count, trunk:iter():length())

   for _, item in trunk:iter() do
      Assert.eq(trunk, item:get_location())
   end
end
