local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local TestUtil = require("api.test.TestUtil")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local data = require("internal.data")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

data:add {
   _type = "base.item",
   _id = "nonuseable",

   dice_x = 2,
   dice_y = 7,
   material = "elona.metal",
   coefficient = 100,

   skill = "elona.bow",

   categories = {
      "elona.equip_ranged_bow",
      "elona.equip_ranged"
   },

   on_use = nil,

   _ext = {
      [IItemEquipment] = {
         hit_bonus = 4,
         damage_bonus = 8,
         equip_slots = { "elona.ranged" },
      }
   }
}

data:add {
   _type = "base.item",
   _id = "useable",

   dice_x = 2,
   dice_y = 7,
   material = "elona.metal",
   coefficient = 100,

   skill = "elona.bow",

   categories = {
      "elona.equip_ranged_bow",
      "elona.equip_ranged"
   },

   on_use = function() end,

   _ext = {
      [IItemEquipment] = {
         hit_bonus = 4,
         damage_bonus = 8,
         equip_slots = { "elona.ranged" },
      }
   }
}

function test_item_event_emitter_callbacks_restored()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      TestUtil.register_map(map)

      local item = Item.create("@test@.useable", nil, nil, {}, player)
      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
   end

   TestUtil.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("@test@.useable", "all", map)

      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))

      Assert.is_truthy(player:equip_item(item))
   end

   TestUtil.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("@test@.useable", "all", map)

      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
   end
end

function test_object_change_prototype__item_callbacks_added()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      TestUtil.register_map(map)

      local item = Item.create("@test@.nonuseable", nil, nil, {}, player)
      Assert.is_falsy(item:has_event_handler("elona_sys.on_item_use"))

      item:change_prototype("@test@.useable")
      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
   end

   TestUtil.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("@test@.useable", "all", map)

      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
   end
end

function test_object_change_prototype__item_callbacks_removed()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      TestUtil.register_map(map)

      local item = Item.create("@test@.useable", nil, nil, {}, player)
      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))

      item:change_prototype("@test@.nonuseable")
      Assert.is_falsy(item:has_event_handler("elona_sys.on_item_use"))
   end

   TestUtil.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("@test@.nonuseable", "all", map)

      Assert.is_falsy(item:has_event_handler("elona_sys.on_item_use"))
   end
end

function test_object_change_prototype__item_callbacks_preserved()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)
   TestUtil.register_map(map)

   local item = Item.create("@test@.useable", nil, nil, {}, player)
   item:connect_self("elona_sys.on_item_use", "Unrelated event", function() end)
   Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))

   item:change_prototype("@test@.nonuseable")
   Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
end
