local TestUtil = require("api.test.TestUtil")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local Action = require("api.Action")
local IItem = require("api.item.IItem")

function test_IItem_get_owning_chara()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      TestUtil.register_map(map)

      local item = Item.create("elona.long_bow", nil, nil, {}, map)

      Assert.eq(nil, IItem.get_owning_chara(item))

      Assert.is_truthy(Action.get(player, item))
      Assert.eq(player, IItem.get_owning_chara(item))
   end

   TestUtil.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("elona.long_bow", "all", map)

      Assert.eq(player, IItem.get_owning_chara(item))

      Assert.is_truthy(player:equip_item(item))
      Assert.eq(player, IItem.get_owning_chara(item))
   end

   TestUtil.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("elona.long_bow", "all", map)

      Assert.eq(player, IItem.get_owning_chara(item))
   end
end
