local data = require("internal.data")
local Enum = require("api.Enum")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local test_util = require("api.test.test_util")
local Assert = require("api.test.Assert")

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

function test_IObject_change_prototype__IEventEmitter_prototype_callbacks_added()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("@test@.noneventful", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      Assert.is_falsy(player:has_event_handler("elona.on_chara_displaced"))

      player:change_prototype("@test@.eventful")
      Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()

      Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))
   end
end

function test_IObject_change_prototype__IEventEmitter_prototype_callbacks_removed()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("@test@.eventful", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))

      player:change_prototype("@test@.noneventful")
      Assert.is_falsy(player:has_event_handler("elona.on_chara_displaced"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()

      Assert.is_falsy(player:has_event_handler("elona.on_chara_displaced"))
   end
end

function test_IObject_change_prototype__IEventEmitter_prototype_callbacks_preserved()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("@test@.eventful", 5, 5, {}, map)
   Chara.set_player(player)
   test_util.register_map(map)

   player:connect_self("elona.on_chara_displaced", "Unrelated event", function() end)
   Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))

   player:change_prototype("@test@.noneventful")
   Assert.is_truthy(player:has_event_handler("elona.on_chara_displaced"))
end
