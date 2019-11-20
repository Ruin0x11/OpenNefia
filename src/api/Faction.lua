local data = require("internal.data")

local Faction = {}

--- Returns the reaction of one faction towards another. Values
--- above 0 indicate friendly relations; values below 0 indicate
--- hostile relations.
---
--- @tparam id:base.faction mine
--- @tparam id:base.faction theirs
function Faction.reaction_towards(mine, theirs)
   local my_faction = data["base.faction"]:ensure(mine)
   local their_faction = data["base.faction"]:ensure(theirs)

   if my_faction == their_faction then
      return 100
   end

   return my_faction.reactions[their_faction._id] or 0
end

return Faction
