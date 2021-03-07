local Assert = require("api.test.Assert")
local Rank = require("mod.elona.api.Rank")

function test_Rank_set()
   Assert.eq(10000, Rank.get("elona.home"))

   Rank.set("elona.home", 0)
   Assert.eq(100, Rank.get("elona.home"))

   Rank.set("elona.home", 100000)
   Assert.eq(10000, Rank.get("elona.home"))
end
