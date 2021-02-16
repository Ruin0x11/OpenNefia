--- @module IFactioned
local Enum = require("api.Enum")
local ICharaParty = require("api.chara.ICharaParty")

local IObject = require("api.IObject")

local IFactioned = class.interface("IFactioned", {}, IObject)

function IFactioned:init()
   self.personal_relations = {}
end

--- Clears a personal relations on this character toward an
--- individual.
function IFactioned:reset_relation_towards(other)
   self.personal_relations[other.uid] = nil
end

function IFactioned:set_relation_towards(other, amount)
   self.personal_relations[other.uid] = amount
end

--- Clears all personal relations on this character.
function IFactioned:reset_all_relations()
   self.personal_relations = {}
end

--- Modifies a personal relation toward an individual.
---
--- @tparam IFactioned other
--- @tparam int delta Can be positive or negative.
function IFactioned:set_relation_towards(other, delta)
   local val = self.personal_relations[other.uid] or 0
   val = val + delta
   self.personal_relations[other.uid] = val

   return val
end

local function compare_relations(our_relation, their_relation)
   if (our_relation == Enum.Relation.Ally and their_relation == Enum.Relation.Ally)
   or (our_relation == Enum.Relation.Enemy and their_relation == Enum.Relation.Enemy) then
      return Enum.Relation.Ally
   end

   if our_relation >= Enum.Relation.Hate then
      if their_relation <= Enum.Relation.Enemy then
         return Enum.Relation.Enemy
      end
   else
      if their_relation >= Enum.Relation.Hate then
         return Enum.Relation.Enemy
      end
   end

   return Enum.Relation.Neutral
end

--- Returns the relation of this object towards another based on
--- faction. Values above 0 indicate friendly relations; values below
--- 0 indicate hostile relations.
---
--- @tparam IFactioned other
--- @treturn Enum.Relation
function IFactioned:base_relation_towards(other)
   if self == other then
      return Enum.Relation.Ally
   end

   local our_relation = self.relation
   local their_relation = other.relation

   return compare_relations(our_relation, their_relation)
end

--- Returns the relation of this object towards another based on
--- faction. Values above 0 indicate friendly relations; values below
--- 0 indicate hostile relations. Characters can have personal
--- relations towards a specific individual, like from stealing an
--- item.
---
--- @tparam IFactioned other
--- @treturn Enum.Relation
function IFactioned:relation_towards(other)
   if self == other then
      return Enum.Relation.Ally
   end

   local us = self
   if class.is_an(ICharaParty, self) then
      us = self:get_party_leader() or us
   end
   local our_relation = us.relation
   local our_personal = us.personal_relations[other.uid]
   if our_personal then
      our_relation = our_personal
   end

   if class.is_an(ICharaParty, other) then
      other = other:get_party_leader() or other
   end
   local their_relation = other.relation
   local their_personal = other.personal_relations[us.uid]
   if their_personal then
      their_relation = their_personal
   end

   return compare_relations(our_relation, their_relation)
end

return IFactioned
