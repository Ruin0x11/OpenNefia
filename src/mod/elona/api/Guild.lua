local Rank = require("mod.elona.api.Rank")

local Guild = {}

function Guild.set_guild(chara, guild_id)
   if guild_id ~= nil then
      data["elona.guild"]:ensure(guild_id)
   end

   for _, member in chara:iter_party_members() do
      -- TODO isolate in capability/mod ext data, and potentially allow joining
      -- more than one guild
      member.guild = guild_id
   end
end

function Guild.calc_mage_guild_quota(place)
   place = place or Rank.get("elona.guild")
   return math.floor(75 - place / 200)
end

return Guild
