local UidTracker = require("api.UidTracker")
local IChara = require("api.chara.IChara")

local parties = class.class("parties")

function parties:init()
   self.uids = UidTracker:new()
   self.parties = {}
   self.chara_to_party = {}
end

function parties:get(id)
   local party = self.parties[id]
   if party == nil then
      return nil
   end
   return party
end

function parties:get_party_id_of_chara(chara)
   class.assert_is_an(IChara, chara)
   local id = self.chara_to_party[chara.uid]
   if id == nil then
      return nil
   end
   return id
end

function parties:add_member(id, chara)
   class.assert_is_an(IChara, chara)
   local party = self:get(id)
   if party == nil then
      error(("unknown party %d"):format(id))
   end
   local exist = self.chara_to_party[chara.uid]
   if exist then
      error(("chara %d is already in party %d"):format(chara.uid, exist))
   end
   table.insert(party.members, chara.uid)
   self.chara_to_party[chara.uid] = id
   if party.leader == nil then
      party.leader = chara.uid
   end
end

function parties:has_member(id, chara)
   class.assert_is_an(IChara, chara)
   local party = self:get(id)
   if party == nil then
      error(("unknown party %d"):format(id))
   end
   return table.index_of(party.members, chara.uid) ~= nil
end

function parties:set_leader(id, chara)
   class.assert_is_an(IChara, chara)
   local party = self:get(id)
   if party == nil then
      error(("unknown party %d"):format(id))
   end
   if self.chara_to_party[chara.uid] ~= id then
      error(("chara %d is not in party %d"):format(chara.uid, id))
   end
   party.leader = chara.uid
end

function parties:get_leader(id)
   local party = self:get(id)
   if party == nil then
      error(("unknown party %d"):format(id))
   end
   return party.leader
end

function parties:remove_member(id, chara)
   class.assert_is_an(IChara, chara)
   local party = self:get(id)
   if party == nil then
      error(("unknown party %d"):format(id))
   end
   local exist = self.chara_to_party[chara.uid]
   if exist ~= id then
      error(("chara %d is not in party %d (%s)"):format(chara.uid, id, exist))
   end
   table.iremove_value(party.members, chara.uid)
   self.chara_to_party[chara.uid] = nil
   if party.leader == chara.uid then
      party.leader = party.members[1]
   end
end

function parties:add_party()
   local id = self.uids:get_next_and_increment()
   self.parties[id] = {
      uid = id,
      members = {},
      metadata = {},
      leader = nil,
   }
   return id
end

function parties:remove_party(id)
   if self.parties[id] == nil then
      error(("unknown party %d"):format(id))
   end
   self.parties[id] = nil
end

return parties
