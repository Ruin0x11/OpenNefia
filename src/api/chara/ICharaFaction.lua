local Chara = require("api.Chara")
local Faction = require("api.Faction")

local ICharaFaction = interface("ICharaFaction", {})

function ICharaFaction:reset_reaction_at(other)
   self.personal_reactions[other.uid] = nil
end

function ICharaFaction:reset_all_reactions(other)
   self.personal_reactions = {}
end

function ICharaFaction:mod_reaction_at(other, delta)
   local val = self.personal_reactions[other.uid] or 0
   val = val + delta
   self.personal_reactions[other.uid] = val

   return val
end

function ICharaFaction:reaction_towards(other, kind)
   local reaction = Faction.reaction_towards(self.faction, other.faction)

   if kind ~= "original" then
      local personal = self.personal_reactions[other.uid]
      reaction = reaction + (personal or 0)
   end

   return reaction
end

function ICharaFaction:mod_hate_at(other, delta)
end

function ICharaFaction:set_hate_at(other, delta)
end

function ICharaFaction:get_hate_at(other, delta)
   return 0
end

function ICharaFaction:act_hostile_towards(other)
   if other:is_player() then
      -- HACK use party system instead
      for _, c in Chara.iter_allies() do
         c.ai_state.player_attacker = self
      end
   end
end

return ICharaFaction
