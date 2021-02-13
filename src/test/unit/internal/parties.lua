local parties = require("internal.parties")
local Chara = require("api.Chara")
local Assert = require("api.test.Assert")

function test_parties_add()
   local parties = parties:new()

   local player = Chara.create("base.player", nil, nil, {ownerless=true})
   local ally = Chara.create("base.player", nil, nil, {ownerless=true})

   local id = parties:add_party()

   Assert.is_true(not parties:has_member(id, player))
   Assert.is_true(not parties:has_member(id, ally))
   Assert.eq(parties:get_leader(id), nil)

   parties:add_member(id, player)
   parties:add_member(id, ally)

   Assert.eq(parties:get_party_id_of_chara(player), id)
   Assert.eq(parties:get_party_id_of_chara(ally), id)
   Assert.is_true(parties:has_member(id, ally))
   Assert.is_true(parties:has_member(id, player))
   Assert.is_true(parties:has_member(id, ally))
   Assert.eq(parties:get_leader(id), player.uid)

   parties:remove_member(id, player)
   Assert.is_true(not parties:has_member(id, player))
   Assert.is_true(parties:has_member(id, ally))
   Assert.eq(parties:get_leader(id), ally.uid)

   parties:remove_member(id, ally)
   Assert.is_true(not parties:has_member(id, player))
   Assert.is_true(not parties:has_member(id, ally))
   Assert.eq(parties:get_leader(id), nil)
end

function test_parties_invalid()
   local parties = parties:new()

   local player = Chara.create("base.player", nil, nil, {ownerless=true})

   Assert.error(function() parties:get_leader(42) end, "unknown party")
   Assert.error(function() parties:has_member(42, player) end, "unknown party")
end

function test_parties_invalid_operation()
   local parties = parties:new()

   local player = Chara.create("base.player", nil, nil, {ownerless=true})
   local id = parties:add_party()

   Assert.error(function() parties:set_leader(id, nil) end)
   Assert.error(function() parties:remove_member(id, player) end)

   parties:add_member(id, player)
   Assert.error(function() parties:add_member(id, player) end, "chara .* is already in party .*")

   parties:remove_member(id, player)
   Assert.error(function() parties:remove_member(id, player) end, "chara .* is not in party .* %(nil%)")
end
