local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")

function test_IChara_swap_places()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 1, 2, {}, map)
   local ally = Chara.create("base.player", 3, 4, {}, map)

   Assert.eq(1, player.x)
   Assert.eq(2, player.y)
   Assert.eq(3, ally.x)
   Assert.eq(4, ally.y)

   player:swap_places(ally)
   Assert.eq(1, ally.x)
   Assert.eq(2, ally.y)
   Assert.eq(3, player.x)
   Assert.eq(4, player.y)

   ally:set_pos(0, 1)
   Assert.eq(nil, Chara.at(1, 2, map))
end
