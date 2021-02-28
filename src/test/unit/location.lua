local test_util = require("test.lib.test_util")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local Log = require("api.Log")
local Inventory = require("api.Inventory")

function test_item_owning_location()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      local item = Item.create("elona.long_bow", nil, nil, {}, player)
      Assert.eq(player, item:get_location())
      Assert.eq(map, player:get_location())
   end

   test_util.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("elona.long_bow", "all", map)

      Assert.eq(player, item:get_location())
      Assert.eq(map, player:get_location())
   end
end

function test_transfer_between_two_nested_inventories()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local shopkeeper = Chara.create("elona.shopkeeper", 1, 2, {}, map)
   shopkeeper.shop_inventory = Inventory:new(nil, "base.item", shopkeeper)

   Item.create("elona.putitoro", nil, nil, {}, shopkeeper.shop_inventory)
   Item.create("elona.long_bow", nil, nil, {}, shopkeeper.shop_inventory)

   local trunk = Item.create("elona.shopkeepers_trunk", 3, 4, {}, map)
   Assert.eq(true, trunk:is_item_container())

   for _, item in shopkeeper.shop_inventory:iter() do
      Assert.is_truthy(trunk:can_take_object(item))
      Assert.is_truthy(trunk:take_object(item))
   end

   for _, item in trunk:iter() do
      Assert.eq(trunk, item:get_location())
   end
end
