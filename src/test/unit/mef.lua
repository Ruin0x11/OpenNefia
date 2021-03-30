local test_util = require("api.test.test_util")
local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Mef = require("api.Mef")
local Assert = require("api.test.Assert")

function test_mef_serialize_origin()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      local mef = Mef.create("elona.potion", 5, 4, { origin = player, duration = -1, power = 50 }, map)
      Assert.eq(mef:get_origin(), player)
   end

   test_util.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local mef = Mef.iter(map):nth(1)

      Assert.eq(mef:get_origin(), player)
   end
end
