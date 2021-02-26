local test_util = require("test.lib.test_util")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local Log = require("api.Log")

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
