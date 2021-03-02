local test_util = require("test.lib.test_util")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local data = require("internal.data")
local Enum = require("api.Enum")

data:add {
   _type = "base.item",
   _id = "nonuseable",

   dice_x = 2,
   dice_y = 7,
   hit_bonus = 4,
   damage_bonus = 8,
   material = "elona.metal",
   equip_slots = { "elona.ranged" },
   coefficient = 100,

   skill = "elona.bow",

   categories = {
      "elona.equip_ranged_bow",
      "elona.equip_ranged"
   },

   on_use = nil
}

data:add {
   _type = "base.item",
   _id = "useable",

   dice_x = 2,
   dice_y = 7,
   hit_bonus = 4,
   damage_bonus = 8,
   material = "elona.metal",
   equip_slots = { "elona.ranged" },
   coefficient = 100,

   skill = "elona.bow",

   categories = {
      "elona.equip_ranged_bow",
      "elona.equip_ranged"
   },

   on_use = function() end
}

function test_event_emitter_callbacks_restored()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      local item = Item.create("base.useable", nil, nil, {}, player)
      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("base.useable", "all", map)

      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))

      Assert.is_truthy(player:equip_item(item))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("base.useable", "all", map)

      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
   end
end

function test_object_change_prototype__item_callbacks_added()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      local item = Item.create("base.nonuseable", nil, nil, {}, player)
      Assert.is_falsy(item:has_event_handler("elona_sys.on_item_use"))

      item:change_prototype("base.useable")
      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("base.useable", "all", map)

      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
   end
end

function test_object_change_prototype__item_callbacks_removed()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      local item = Item.create("base.useable", nil, nil, {}, player)
      Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))

      item:change_prototype("base.nonuseable")
      Assert.is_falsy(item:has_event_handler("elona_sys.on_item_use"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local item = Item.find("base.nonuseable", "all", map)

      Assert.is_falsy(item:has_event_handler("elona_sys.on_item_use"))
   end
end

function test_object_change_prototype__item_callbacks_preserved()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.eventful", 5, 5, {}, map)
   Chara.set_player(player)
   test_util.register_map(map)

   local item = Item.create("base.useable", nil, nil, {}, player)
   item:connect_self("elona_sys.on_item_use", "Unrelated event", function() end)
   Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))

   item:change_prototype("base.nonuseable")
   Assert.is_truthy(item:has_event_handler("elona_sys.on_item_use"))
end

data:add {
   _type = "base.chara",
   _id = "noneventful",

   loot_type = "elona.humanoid",
   level = 1,
   relation = Enum.Relation.Enemy,
   race = "elona.slime",
   class = "elona.predator",
   fltselect = Enum.FltSelect.Sp,
   coefficient = 400,

   events = nil
}

data:add {
   _type = "base.chara",
   _id = "eventful",

   loot_type = "elona.humanoid",
   level = 1,
   relation = Enum.Relation.Enemy,
   race = "elona.slime",
   class = "elona.predator",
   fltselect = Enum.FltSelect.Sp,
   coefficient = 400,

   events = {
      {
         id = "elona.on_chara_displaced",
         name = "Test event",

         callback = function(self, params)
         end
      }
   }
}

function test_object_change_prototype__IEventEmitter_prototype_callbacks_added()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.noneventful", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)
      Assert.is_falsy(player:has_event_handler("elona.on_chara_displaced"))

      player:change_prototype("base.eventful")
      Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()

      Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))
   end
end

function test_object_change_prototype__IEventEmitter_prototype_callbacks_removed()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.eventful", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)
      Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))

      player:change_prototype("base.noneventful")
      Assert.is_falsy(player:has_event_handler("elona.on_chara_displaced"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()

      Assert.is_falsy(player:has_event_handler("elona.on_chara_displaced"))
   end
end

function test_object_change_prototype__IEventEmitter_prototype_callbacks_preserved()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.eventful", 5, 5, {}, map)
   Chara.set_player(player)
   test_util.register_map(map)

   player:connect_self("elona.on_chara_displaced", "Unrelated event", function() end)
   Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))

   player:change_prototype("base.noneventful")
   Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))
end
