local Chara = require("api.Chara")
local Faction = require("api.Faction")
local IObject = require("api.IObject")

local IFactioned = class.interface("IFactioned", {}, IObject)

function IFactioned:init()
   self.personal_reactions = {}
end

function IFactioned:reset_reaction_at(other)
   self.personal_reactions[other.uid] = nil
end

function IFactioned:reset_all_reactions()
   self.personal_reactions = {}
end

function IFactioned:mod_reaction_at(other, delta)
   local val = self.personal_reactions[other.uid] or 0
   val = val + delta
   self.personal_reactions[other.uid] = val

   return val
end

function IFactioned:reaction_towards(other, kind)
   local reaction = Faction.reaction_towards(self:calc("faction"), other:calc("faction"))

   if kind ~= "original" then
      local personal = self.personal_reactions[other.uid]
      reaction = reaction + (personal or 0)
   end

   return reaction
end

function IFactioned:mod_hate_at(other, delta)
end

function IFactioned:set_hate_at(other, delta)
end

function IFactioned:get_hate_at(other, delta)
   return 0
end

return IFactioned
