local Chara = require("api.Chara")
local Faction = require("api.Faction")
local IFactioned = require("api.IFactioned")

local ICharaParty = class.interface("ICharaParty", {}, IFactioned)

function ICharaParty:is_party_leader()
   return self:is_player()
end

function ICharaParty:is_party_leader_of(other)
   return other:is_allied()
end

function ICharaParty:is_in_same_faction(other)
   return self:calc("faction") == other:calc("faction")
end

function ICharaParty:get_party_leader()
   if self:is_allied() then
      return Chara.player()
   end

   return nil
end

--- True if this character is part of a party.
--- Currently only valid for the player.
---
--- @treturn bool
function ICharaParty:is_in_party()
   return self:is_allied()
end

--- True if this character is sided with the player, or is the player
--- themselves.
---
--- @treturn bool
function ICharaParty:is_allied()
   return self:is_player() or self:is_ally()
end

--- Iterates the characters in this character's party.
--- Currently only valid for the player.
---
--- @treturn Iterator(IChara)
function ICharaParty:iter_party()
   if self:is_in_party() then
      return Chara.iter_party()
   end

   return fun.iter({})
end

function ICharaParty:act_hostile_towards(other)
   if other:is_party_leader() then
      for _, c in other:iter_party() do
         c.ai_state.leader_attacker = self
      end
   end
end

function ICharaParty:can_recruit_allies()
   return true
end

return ICharaParty
