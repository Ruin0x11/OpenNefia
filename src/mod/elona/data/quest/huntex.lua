local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")

local huntex = {
   _id = "huntex",
   _type = "elona_sys.quest",

   elona_id = 1010,
   ordering = 20000,
   client_chara_type = 1,
   reward = "elona.supply",
   reward_fix = 140,

   min_fame = 30000,
   chance = 13,

   params = { enemy_id = "string" },

   reward_count = function() return Rand.rnd(Rand.rnd(4) + 1) + 3 end,

   difficulty = function()
      local difficulty = Rand.rnd(Chara.player():calc("level") + 10) + Rand.rnd(Chara.player():calc("fame") / 2500 + 1)
      difficulty = Calc.round_margin(difficulty, Chara.player():calc("level"))
      return difficulty
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   generate = function(self, client)
      local min_level = math.clamp(math.floor(self.difficulty / 7), 5, 30)
      local enemy_id = Calc.hunt_enemy_id(self.difficulty, min_level)

      self.params = {
         enemy_id = enemy_id,
         enemy_level = math.floor(self.difficulty * 3 / 2)
      }

      return true
   end,
   locale_data = function(self)
      return { objective = self.params.enemy_id, enemy_level = self.params.enemy_level }
   end,

   prevents_pickpocket = true
}
-- data:add(huntex)
