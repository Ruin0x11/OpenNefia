local data = require("internal.data")

local Faction = {}

function Faction.reaction_towards(mine, theirs)
   local my_faction = data["base.faction"][mine]
   local their_faction = data["base.faction"][theirs]

   if not my_faction then
      error(string.format("Unknown faction: %s %s", tostring(mine)))
   end

   if my_faction == their_faction then
      return 100
   end

   return my_faction.reactions[their_faction._id] or 0
end

return Faction
