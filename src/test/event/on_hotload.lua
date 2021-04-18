local TestUtil = require("api.test.TestUtil")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Map = require("api.Map")
local Assert = require("api.test.Assert")

function test_hotload_IEventEmitter_events()
   TestUtil.hotload_code("mod.@test@.data.chara", TestUtil.TEST_MOD_ID, [[
data:add {
   _type = "base.chara",
   _id = "hotload_events"
}
]])

   local map = InstancedMap:new(10, 10)
   local chara = Chara.create("@test@.hotload_events", 5, 5, {}, map)
   local player = TestUtil.set_player(map)
   Map.set_map(map)

   Assert.eq(false, chara:has_event_handler("base.on_chara_moved"))

   TestUtil.hotload_code("mod.@test@.data.chara", TestUtil.TEST_MOD_ID, [[
data:add {
   _type = "base.chara",
   _id = "hotload_events",

   events = {
      {
         id = "base.on_chara_moved",
         name = "Test event",

         callback = function(chara)
            chara.hp = 42
         end
      }
   }
}
]])

   Assert.eq(true, chara:has_event_handler("base.on_chara_moved"))

   TestUtil.hotload_code("mod.@test@.data.chara", TestUtil.TEST_MOD_ID, [[
data:add {
   _type = "base.chara",
   _id = "hotload_events"
}
]])

   -- XXX: removing old events is broken since can't compare the previous
   -- instance before hotloading
   Assert.eq(true, chara:has_event_handler("base.on_chara_moved"))
end
