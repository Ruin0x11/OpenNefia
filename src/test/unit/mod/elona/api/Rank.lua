local Assert = require("api.test.Assert")
local Rank = require("mod.elona.api.Rank")
local I18N = require("api.I18N")

function test_Rank_set()
   Assert.eq(10000, Rank.get("elona.home"))

   Rank.set("elona.home", 0)
   Assert.eq(100, Rank.get("elona.home"))

   Rank.set("elona.home", 100000)
   Assert.eq(10000, Rank.get("elona.home"))
end

function test_Rank_modify()
   Assert.eq(10000, Rank.get("elona.home"))

   Rank.modify("elona.home", 100)
   Assert.eq(9424, Rank.get("elona.home"))

   Rank.modify("elona.home", 100000)
   Assert.eq(100, Rank.get("elona.home"))

   Rank.modify("elona.home", 100000)
   Assert.eq(100, Rank.get("elona.home"))
end

function test_Rank_title()
   Assert.eq(I18N.get("rank.elona.home.titles._9"), Rank.title("elona.home"))

   Rank.set("elona.home", 100)
   Assert.eq(I18N.get("rank.elona.home.titles._0"), Rank.title("elona.home"))

   -- Fishing doesn't have a title for some reason.
   Assert.eq(nil, Rank.title("elona.fishing"))
end

function test_Rank_get_decay_period_days()
   Assert.eq(nil, Rank.get_decay_period_days("elona.home"))
   Assert.eq(20, Rank.get_decay_period_days("elona.arena"))
   Assert.eq(60, Rank.get_decay_period_days("elona.pet_arena"))
end

function test_Rank__invalid_rank_id()
   Assert.throws_error(function() Rank.get("dood") end, "No instance of 'elona.rank'")
   Assert.throws_error(function() Rank.set("dood", 100) end, "No instance of 'elona.rank'")
   Assert.throws_error(function() Rank.modify("dood", 100) end, "No instance of 'elona.rank'")
end
