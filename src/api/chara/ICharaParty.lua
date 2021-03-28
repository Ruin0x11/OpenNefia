local Chara = require("api.Chara")
local save = require("internal.global.save")
local MapObject = require("api.MapObject")
local Gui = require("api.Gui")

local ICharaParty = class.interface("ICharaParty", {})

function ICharaParty:is_party_leader()
   local parties = save.base.parties
   local party_id = parties:get_party_id_of_chara(self)
   if not party_id then
      return false
   end

   return parties:get(party_id).leader == self.uid
end

function ICharaParty:is_party_leader_of(other)
   local parties = save.base.parties
   local party_id = parties:get_party_id_of_chara(self)
   if not party_id then
      return false
   end

   local party = parties:get(party_id)
   return party.leader == self.uid
      and party.leader ~= other.uid
      and parties:has_member(party_id, other)
end

function ICharaParty:is_in_same_party(other)
   local parties = save.base.parties
   local my_id = parties:get_party_id_of_chara(self)
   local their_id = parties:get_party_id_of_chara(other)
   return my_id and their_id and my_id == their_id
end

function ICharaParty:get_party_leader()
   local parties = save.base.parties
   local party_id = parties:get_party_id_of_chara(self)
   if not party_id then
      return nil
   end

   local map = self:current_map()
   if map == nil then
      return nil
   end

   local leader_uid = parties:get(party_id).leader
   return map:get_object_of_type("base.chara", leader_uid)
end

--- True if this character is part of a party.
--- Currently only valid for the player.
---
--- @treturn bool
function ICharaParty:get_party()
   return save.base.parties:get_party_id_of_chara(self)
end

--- True if this character is sided with the player, or is the player
--- themselves.
---
--- @treturn bool
function ICharaParty:is_in_player_party()
   return self:is_player() or self:is_ally()
end

--- Returns true if this character is an ally of the player.
---
--- @treturn bool
function ICharaParty:is_ally()
   local player = Chara.player()
   if player == nil then
      return false
   end
   return player:is_party_leader_of(self)
end

local function mkiter(and_self)
   return function(self, map)
      if not self:get_party() then
         return fun.iter {}
      end

      local iter = fun.iter(save.base.parties:get(self:get_party()).members)

      if not and_self then
         iter = iter:filter(function(uid) return uid ~= self.uid end)
      end

      map = map or self:current_map()
      if map == nil then
         return fun.iter {}
      end

      return iter:map(function(uid) return map:get_object_of_type("base.chara", uid) end):filter(fun.op.truth)
   end
end

--- Iterates the characters in this character's party.
---
--- @treturn Iterator(IChara)
ICharaParty.iter_party_members = mkiter(true)

--- Iterates the characters in this character's party excluding self.
---
--- @treturn Iterator(IChara)
ICharaParty.iter_other_party_members = mkiter(false)

function ICharaParty:act_hostile_towards(other)
   if not self:is_in_player_party() or other:is_player() then
      return
   end

   self:emit("base.on_act_hostile_towards", {target=other})
end

function ICharaParty:can_recruit_allies()
   local parties = save.base.parties
   local party_id = parties:get_party_id_of_chara(self)
   if not party_id then
      return false
   end

   local party = parties:get(party_id)
   local is_leader = party.leader == self.uid
   if not is_leader then
      return false
   end

   local can_recruit = true
   can_recruit = self:emit("base.on_chara_calc_can_recruit_allies", nil, can_recruit)

   return can_recruit
end

--- Attempts to recruit a character as an ally of this character.
---
--- @tparam IChara ally
--- @tparam[opt] bool no_message
--- @treturn bool true on success.
function ICharaParty:recruit_as_ally(target, no_message)
   assert(MapObject.is_map_object(target, "base.chara"))

   if not self:get_party() then
      local party_id = save.base.parties:add_party()
      save.base.parties:add_member(party_id, self)
   end

   if self == target then
      return false
   end

   if self:is_party_leader_of(target) then
      return false
   end

   -- TODO make into event returning a turn result instead? Elona+ has a special
   -- error message if the target is in a tag team.
   if not self:can_recruit_allies() then
      Gui.mes("action.ally_joins.party_full")
      return false
   end

   save.base.parties:add_member(self:get_party(), target)

   target.relation = self.relation
   target:refresh()

   if self:get_target() == target then
      self:set_target(nil)
   end

   if self:is_player() and not no_message then
      Gui.mes_c("action.ally_joins.success", "Yellow", target)
      Gui.play_sound("base.pray1");
   end
   target:emit("base.on_recruited_as_ally", { no_message = no_message })

   return true
end

return ICharaParty
