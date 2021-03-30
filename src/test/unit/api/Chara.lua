local Chara = require("api.Chara")
local TestUtil = require("api.test.TestUtil")
local Map = require("api.Map")
local Assert = require("api.test.Assert")
local save = require("internal.global.save")
local InstancedMap = require("api.InstancedMap")

function test_map_travel_transfers_staying()
   local map = InstancedMap:new(10, 10)
   local player = TestUtil.set_player(map)
   local chara = Chara.create("elona.putit", 5, 5, {}, map)

   Assert.eq(1, Chara.iter_allies(map):length())

   Assert.is_truthy(player:recruit_as_ally(chara))
   Assert.eq(2, Chara.iter_allies(map):length())

   chara:kill()
   Assert.eq("PetDead", chara.state)
   Assert.eq(2, Chara.iter_allies(map):length())
end
