local parties = require("internal.parties")
local Chara = require("api.Chara")
local Test = require("api.test.Test")

function test_parties_add()
   local parties = parties:new()

   local player = Chara.create("base.player", nil, nil, {ownerless=true})
   local ally = Chara.create("base.player", nil, nil, {ownerless=true})

   local id = parties:add_party()

   assert(not parties:has_member(id, player))
   assert(not parties:has_member(id, ally))
   assert(parties:get_leader(id) == nil)

   parties:add_member(id, player)
   parties:add_member(id, ally)

   assert(parties:get_party_id_of_chara(player) == id)
   assert(parties:get_party_id_of_chara(ally) == id)
   assert(parties:has_member(id, ally))
   assert(parties:has_member(id, player))
   assert(parties:has_member(id, ally))
   assert(parties:get_leader(id) == player.uid)

   parties:remove_member(id, player)
   assert(not parties:has_member(id, player))
   assert(parties:has_member(id, ally))
   assert(parties:get_leader(id) == ally.uid)

   parties:remove_member(id, ally)
   assert(not parties:has_member(id, player))
   assert(not parties:has_member(id, ally))
   assert(parties:get_leader(id) == nil)
end

function test_parties_invalid()
   local parties = parties:new()

   local player = Chara.create("base.player", nil, nil, {ownerless=true})

   assert(Test.assert_error(function() parties:get_leader(42) end, "unknown party"))
   assert(Test.assert_error(function() parties:has_member(42, player) end, "unknown party"))
end

function test_parties_invalid_operation()
   local parties = parties:new()

   local player = Chara.create("base.player", nil, nil, {ownerless=true})
   local id = parties:add_party()

   assert(Test.assert_error(function() parties:set_leader(id, nil) end))
   assert(Test.assert_error(function() parties:remove_member(id, player) end))

   parties:add_member(id, player)
   assert(Test.assert_error(function() parties:add_member(id, player) end, "chara .* is already in party .*"))

   parties:remove_member(id, player)
   assert(Test.assert_error(function() parties:remove_member(id, player) end, "chara .* is not in party .* %(nil%)"))
end
