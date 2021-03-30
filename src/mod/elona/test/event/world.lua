local Rank = require("mod.elona.api.Rank")
local World = require("api.World")
local Assert = require("api.test.Assert")
local Inventory = require("api.Inventory")
local save = require("internal.global.save")
local Rand = require("api.Rand")
local test_util = require("test.lib.test_util")

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

function test_salary_is_skipped()
   save.base.date.day = 14

   local inv = Inventory.get_or_create("elona.salary_chest")
   Assert.eq(0, inv:len())

   Rand.set_seed(0)
   -- NOTE: Skips over the 15th's salary. We may want to change this.
   World.pass_time_in_seconds(60 * 60 * 24 * 2)
   Assert.eq(0, inv:len())
end

function test_salary_is_generated()
   save.base.date.day = 14
   local player = test_util.set_player()
   player.level = 10
   player.fame = 1000
   Rank.set("elona.home", 5000)

   local inv = Inventory.get_or_create("elona.salary_chest")
   Assert.eq(0, inv:len())

   Rand.set_seed(0)
   World.pass_time_in_seconds(60 * 60 * 24 * 1 + 1)

   Assert.eq(3, inv:len())
   local gold = inv:iter():nth(1)
   Assert.eq("elona.gold_piece", gold._id)
   Assert.eq(1630, gold.amount)
end

function test_bill_not_generated_below_sixth_level()
   save.base.date.day = 30
   local player = test_util.set_player()
   player.level = 5
   player.fame = 1000
   Rank.set("elona.home", 5000)

   local inv = Inventory.get_or_create("elona.salary_chest")
   Assert.eq(0, inv:len())

   Rand.set_seed(0)
   World.pass_time_in_seconds(60 * 60 * 24 * 1 + 1)

   Assert.eq(3, inv:len())
   local gold = inv:iter():nth(1)
   Assert.eq("elona.gold_piece", gold._id)
   Assert.eq(1630, gold.amount)
   Assert.eq(false, inv:iter():any(function(i) return i._id == "elona.bill" end))
end

function test_salary_and_bill_are_generated()
   save.base.date.day = 30
   local player = test_util.set_player()
   player.level = 10
   player.fame = 1000
   Rank.set("elona.home", 5000)

   local inv = Inventory.get_or_create("elona.salary_chest")
   Assert.eq(0, inv:len())

   Rand.set_seed(0)
   World.pass_time_in_seconds(60 * 60 * 24 * 1 + 1)

   Assert.eq(4, inv:len())
   local gold = inv:iter():nth(1)
   Assert.eq("elona.gold_piece", gold._id)
   Assert.eq(1630, gold.amount)
   Assert.eq(true, inv:iter():any(function(i) return i._id == "elona.bill" end))
end
