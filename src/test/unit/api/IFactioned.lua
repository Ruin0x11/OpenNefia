local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local IFactioned = require("api.IFactioned")
local Enum = require("api.Enum")
local Assert = require("api.test.Assert")

function test_IFactioned_party()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   local ally = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)

   Assert.eq(Enum.Relation.Ally, player.relation)
   Assert.eq(Enum.Relation.Neutral, ally.relation)

   Assert.eq(Enum.Relation.Neutral, IFactioned.relation_towards(player, ally))
   Assert.eq(Enum.Relation.Neutral, IFactioned.relation_towards(ally, player))

   ally.relation = Enum.Relation.Enemy

   Assert.eq(Enum.Relation.Enemy, IFactioned.relation_towards(player, ally))
   Assert.eq(Enum.Relation.Enemy, IFactioned.relation_towards(ally, player))

   Assert.is_true(player:recruit_as_ally(ally))

   Assert.eq(Enum.Relation.Ally, IFactioned.relation_towards(player, ally))
   Assert.eq(Enum.Relation.Ally, IFactioned.relation_towards(ally, player))

   local leader = Chara.create("base.player", 5, 5, {}, map)
   local other_ally = Chara.create("base.player", 5, 5, {}, map)
   Assert.is_true(leader:recruit_as_ally(other_ally))

   leader.relation = Enum.Relation.Enemy

   Assert.eq(Enum.Relation.Ally, IFactioned.relation_towards(leader, other_ally))
   Assert.eq(Enum.Relation.Ally, IFactioned.relation_towards(other_ally, leader))

   local us = player:iter_party_members()
   local them = leader:iter_party_members()

   for _, ally in us:unwrap() do
      for _, enemy in them:unwrap() do
         Assert.eq(Enum.Relation.Enemy, IFactioned.relation_towards(ally, enemy))
         Assert.eq(Enum.Relation.Enemy, IFactioned.relation_towards(enemy, ally))
      end
   end
end

function test_IFactioned_party_personal_relation()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   local ally = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)
   Assert.is_true(player:recruit_as_ally(ally))

   local leader = Chara.create("base.player", 5, 5, {}, map)
   local other_ally = Chara.create("base.player", 5, 5, {}, map)
   leader.relation = Enum.Relation.Neutral
   Assert.is_true(leader:recruit_as_ally(other_ally))

   local function test(relation)
      Assert.eq(relation, IFactioned.relation_towards(player, leader))
      Assert.eq(relation, IFactioned.relation_towards(leader, player))
   end

   test(Enum.Relation.Neutral)

   leader:set_relation_towards(player, Enum.Relation.Dislike)
   test(Enum.Relation.Neutral)

   leader:set_relation_towards(player, Enum.Relation.Enemy)
   test(Enum.Relation.Enemy)

   leader:reset_all_relations()
   test(Enum.Relation.Neutral)

   -- TODO maybe ally actions could cause aggro. but vanilla doesn't allow this.
   leader:set_relation_towards(ally, Enum.Relation.Enemy)
   test(Enum.Relation.Neutral)

   leader:reset_all_relations()
   test(Enum.Relation.Neutral)
end
