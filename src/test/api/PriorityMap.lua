local PriorityMap = require("api.PriorityMap")
local Assert = require("api.test.Assert")

function test_PriorityMap_set()
   local map = PriorityMap:new()

   map:set("elona.figure", "Figure", 150000)
   map:set("elona.card", "Card", 25000)
   map:set("elona.player_light", "Player Light", 50000)

   local iter = fun.wrap(map:iter())

   Assert.eq("Card", iter:nth(1))
   Assert.eq("Player Light", iter:nth(2))
   Assert.eq("Figure", iter:nth(3))
end

function test_PriorityMap_set_removal()
   local map = PriorityMap:new()

   map:set("elona.figure", "Figure", 150000)
   map:set("elona.card", "Card", 25000)
   map:set("elona.player_light", "Player Light", 50000)
   map:set("elona.player_light", nil)

   local iter = fun.wrap(map:iter())

   Assert.eq("Card", iter:nth(1))
   Assert.eq("Figure", iter:nth(2))
end
