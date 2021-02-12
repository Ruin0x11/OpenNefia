local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local ICharaParty = require("api.chara.ICharaParty")
local save = require("internal.global.save")

function test_ICharaParty_get_party()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   local ally = Chara.create("base.player", 5, 5, {}, map)

   assert(ICharaParty.get_party(player) == nil)
   assert(ICharaParty.get_party(ally) == nil)

   Chara.set_player(player)
   assert(ICharaParty.get_party(player) ~= nil)

   player:recruit_as_ally(ally)

   assert(ICharaParty.get_party(ally) ~= nil)
end

function test_ICharaParty_is_in_same_party()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   local ally = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)

   assert(not ICharaParty.is_in_same_party(player, ally))
   assert(not ICharaParty.is_in_same_party(ally, player))

   assert(player:recruit_as_ally(ally))

   assert(ICharaParty.is_in_same_party(player, ally))
   assert(ICharaParty.is_in_same_party(ally, player))

   local leader = Chara.create("base.player", 5, 5, {}, map)
   local other_ally = Chara.create("base.player", 5, 5, {}, map)
   local party_id = save.base.parties:add_party()
   save.base.parties:add_member(party_id, leader)
   assert(leader:recruit_as_ally(other_ally))

   assert(ICharaParty.is_in_same_party(leader, other_ally))
   assert(not ICharaParty.is_in_same_party(leader, player))
end

function test_ICharaParty_is_party_leader_of()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   local ally = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)

   assert(not ICharaParty.is_party_leader_of(player, ally))
   assert(not ICharaParty.is_party_leader_of(ally, player))

   assert(player:recruit_as_ally(ally))

   assert(ICharaParty.is_party_leader_of(player, ally))
   assert(not ICharaParty.is_party_leader_of(ally, player))

   local leader = Chara.create("base.player", 5, 5, {}, map)
   local other_ally = Chara.create("base.player", 5, 5, {}, map)
   local party_id = save.base.parties:add_party()
   save.base.parties:add_member(party_id, leader)
   assert(leader:recruit_as_ally(other_ally))

   assert(not ICharaParty.is_party_leader_of(player, leader))
   assert(not ICharaParty.is_party_leader_of(player, other_ally))
end

function test_ICharaParty_is_in_player_party()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   local ally = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)

   assert(player:is_in_player_party())
   assert(not ally:is_in_player_party())

   assert(player:recruit_as_ally(ally))

   assert(player:is_in_player_party())
   assert(ally:is_in_player_party())

   local leader = Chara.create("base.player", 5, 5, {}, map)
   local other_ally = Chara.create("base.player", 5, 5, {}, map)
   local party_id = save.base.parties:add_party()
   save.base.parties:add_member(party_id, leader)
   assert(leader:recruit_as_ally(other_ally))

   assert(not ICharaParty.is_in_player_party(leader))
   assert(not ICharaParty.is_in_player_party(other_ally))
end

function test_ICharaParty_is_ally()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   local ally = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)

   assert(not player:is_ally())
   assert(not ally:is_ally())

   assert(player:recruit_as_ally(ally))

   assert(not player:is_ally())
   assert(ally:is_ally())

   local leader = Chara.create("base.player", 5, 5, {}, map)
   local other_ally = Chara.create("base.player", 5, 5, {}, map)
   local party_id = save.base.parties:add_party()
   save.base.parties:add_member(party_id, leader)
   assert(leader:recruit_as_ally(other_ally))

   assert(not ICharaParty.is_ally(leader))
   assert(not ICharaParty.is_ally(other_ally))
end

function test_ICharaParty_iter_party_members()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   local ally = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)

   assert(player:iter_party_members():length() == 1)
   assert(ally:iter_party_members():length() == 0)

   assert(player:recruit_as_ally(ally))

   assert(player:iter_party_members():length() == 2)
   assert(ally:iter_party_members():length() == 2)
end

function test_ICharaParty_iter_other_party_members()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   local ally = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)

   assert(player:iter_other_party_members():length() == 0)
   assert(ally:iter_other_party_members():length() == 0)

   assert(player:recruit_as_ally(ally))

   assert(player:iter_other_party_members():length() == 1)
   assert(ally:iter_other_party_members():length() == 1)
end
