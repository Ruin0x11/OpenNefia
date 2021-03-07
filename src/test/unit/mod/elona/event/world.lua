local Rank = require("mod.elona.api.Rank")
local World = require("api.World")
local Assert = require("api.test.Assert")

function test_rank_decay()
   Rank.set("elona.arena", 100)
   Assert.eq(100, Rank.get("elona.arena"))

   World.pass_time_in_seconds(60 * 60 * 24 * 21)
   Assert.eq(208, Rank.get("elona.arena"))
end

function test_rank_decay_reset_by_rank_modify()
   -- Decay time gets initialized to 0 days, so pass one day first.
   World.pass_time_in_seconds(60 * 60 * 24)

   Rank.set("elona.arena", 100)
   Assert.eq(100, Rank.get("elona.arena"))

   World.pass_time_in_seconds(60 * 60 * 24 * 19)
   Rank.modify("elona.arena", 1)
   World.pass_time_in_seconds(60 * 60 * 24 * 19)

   Assert.eq(100, Rank.get("elona.arena"))
end
