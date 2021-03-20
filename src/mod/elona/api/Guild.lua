local Rank = require("mod.elona.api.Rank")
local Enum = require("api.Enum")
local Charagen = require("mod.elona.api.Charagen")
local Rand = require("api.Rand")
local Chara = require("api.Chara")

local Guild = {}

function Guild.set_guild(chara, guild_id)
   if guild_id ~= nil then
      data["elona.guild"]:ensure(guild_id)
   end

   local old_guild_id = chara.guild

   for _, member in chara:iter_party_members() do
      -- TODO isolate in capability/mod ext data, and potentially allow joining
      -- more than one guild
      member.guild = guild_id
   end

   chara:emit("elona.on_chara_changed_guild", {guild_id=guild_id, old_guild_id=old_guild_id})
end

function Guild.calc_mage_guild_quota(place)
   place = place or Rank.get("elona.guild")
   return math.floor(75 - place / 200)
end

function Guild.is_valid_fighter_guild_target(chara)
   if chara.rarity < 70 * 1000 then
      return false
   end

   if chara.relation ~= Enum.Relation.Enemy then
      return false
   end

   if chara.quality >= Enum.Quality.Great then
      return false
   end

   return true
end

function Guild.random_fighter_guild_target_id(level)
   -- >>>>>>>> shade2/chat.hsp:1840 				repeat  ...
   local chara_filter = {
      level = level,
      ownerless = true
   }

   local gen = function(i)
      if i > 100 then
         chara_filter.level = math.max(math.floor(chara_filter.level * 0.9), 1)
      end
      return Charagen.create(nil, nil, chara_filter)
   end

   return fun.range(1000):map(gen):filter(Guild.is_valid_fighter_guild_target):extract("_id"):nth(1)
   -- <<<<<<<< shade2/chat.hsp:1849 				chara_vanquish nc ..
end

function Guild.calc_fighter_guild_target_level(player)
   player = player or Chara.player()
   return player.level + 10
end

function Guild.calc_fighter_guild_target_count()
   return 2 + Rand.rnd(3)
end

function Guild.calc_thief_guild_quota(place)
   place = place or Rank.get("elona.guild")
   return (10000 - place) * 6 + 1000
end

return Guild
