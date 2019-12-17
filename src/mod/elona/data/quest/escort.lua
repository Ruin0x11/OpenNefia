local Rand = require("api.Rand")
local Quest = require("mod.elona_sys.api.Quest")
local Pos = require("api.Pos")
local Chara = require("api.Chara")

local escort = {
   _id = "escort",
   _type = "elona_sys.quest",

   elona_id = 1007,
   ordering = 40000,
   client_chara_type = 6,
   reward = "elona.supply",
   reward_fix = 140,

   min_fame = 0,
   chance = 11,

   params = { escort_difficulty = "number", destination_map_uid = "number" },

   difficulty = 0,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   locale_data = function(self)
      return {map = self.params.destination_map_name}, "difficulty._" .. self.params.escort_difficulty
   end
}

function escort.generate(self, client, start)
   local dest = Rand.choice(Quest.iter_towns():filter(function(t) return t.uid ~= start.uid end))
   if not dest then
      return false, "No destinations to escort to."
   end

   local escort_difficulty = Rand.rnd(3)
   local dist = Pos.dist(start.world_map_x, start.world_map_y, dest.world_map_x, dest.world_map_y)

   if escort_difficulty == 0 then
      self.reward_fix = 140 + dist * 2
      self.deadline_days = Rand.rnd(8) + 6
      self.difficulty = math.clamp(Rand.rnd(Chara.player():calc("level") + 10)
                                      + Rand.rnd(Chara.player():calc("fame") / 500 + 1)
                                      + 1,
                                   1, 80)
   elseif escort_difficulty == 1 then
      self.reward_fix = 130 + dist * 2
      self.deadline_days = Rand.rnd(5) + 2
      self.difficulty = math.clamp(math.floor(self.reward_fix / 10 + 1), 1, 40)
   elseif escort_difficulty == 2 then
      self.reward_fix = 80 + dist * 2
      self.deadline_days = Rand.rnd(8) + 6
      self.difficulty = math.clamp(math.floor(self.reward_fix / 20) + 1, 1, 40)
   end

   if start.gen_id == "elona.noyel" or dest.gen_id == "elona.noyel" then
      self.reward_fix = math.floor(self.reward_fix * 180 / 100)
   end

   self.params = {
      escort_difficulty = escort_difficulty,
      destination_map_uid = dest.uid,
      destination_map_name = dest.name
   }

   return true
end

data:add(escort)
