local Chara = require("api.Chara")
local Faction = require("api.Faction")
local IFactioned = require("api.IFactioned")

local ICharaParty = interface("ICharaParty", {}, IFactioned)

function ICharaParty:is_party_leader()
   return self:is_player()
end

function ICharaParty:is_party_leader_of(other)
   return other:is_in_party()
end

function ICharaParty:get_party_leader()
   if self:is_in_party() then
      return Chara.player()
   end

   return nil
end

function ICharaParty:is_in_party()
   return self:is_player() or self:is_ally()
end

function ICharaParty:get_party()
   if self:is_in_party() then
      return Chara.iter_allies()
   end

   return nil
end

function ICharaParty:act_hostile_towards(other)
   if other:is_party_leader() then
      for _, c in other:get_party() do
         c.ai_state.leader_attacker = self
      end
   end
end

return ICharaParty
