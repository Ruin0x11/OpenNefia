--- @module IFactioned

local Chara = require("api.Chara")
local Faction = require("api.Faction")
local IObject = require("api.IObject")

local IFactioned = class.interface("IFactioned", {}, IObject)

function IFactioned:init()
   self.personal_reactions = {}
end

--- Clears a personal reactions on this character toward an
--- individual.
function IFactioned:reset_reaction_at(other)
   self.personal_reactions[other.uid] = nil
end

--- Clears all personal reactions on this character.
function IFactioned:reset_all_reactions()
   self.personal_reactions = {}
end

--- Modifies a personal reaction toward an individual.
---
--- @tparam IFactioned other
--- @tparam int delta Can be positive or negative.
function IFactioned:mod_reaction_at(other, delta)
   local val = self.personal_reactions[other.uid] or 0
   val = val + delta
   self.personal_reactions[other.uid] = val

   return val
end

--- Returns the reaction of this object towards another based on
--- faction. Values above 0 indicate friendly relations; values below
--- 0 indicate hostile relations. Characters can have personal
--- reactions towards a specific individual, like from stealing an
--- item. Pass "original" to the `kind` field to bypass this and
--- obtain the unmodified reaction.
---
--- @tparam IFactioned other
--- @tparam[opt] string kind If "original", ignore temporary personal reactions.
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
