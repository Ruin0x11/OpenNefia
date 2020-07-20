--- @module IFactioned

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

function IFactioned:set_reaction_at(other, amount)
   self.personal_reactions[other.uid] = amount
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
--- 0 indicate hostile relations.
---
--- @tparam IFactioned other
--- @treturn number Friendly if positive, enemy if negative
function IFactioned:base_reaction_towards(other, kind)
   return Faction.reaction_towards(self:calc("faction"), other:calc("faction"))
end

--- Returns the reaction of this object towards another based on
--- faction. Values above 0 indicate friendly relations; values below
--- 0 indicate hostile relations. Characters can have personal
--- reactions towards a specific individual, like from stealing an
--- item.
---
--- @tparam IFactioned other
--- @treturn number Friendly if positive, enemy if negative
function IFactioned:reaction_towards(other, kind)
   local reaction = self:base_reaction_towards(other)
   local personal = self.personal_reactions[other.uid]
   if personal then
      reaction = personal
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
