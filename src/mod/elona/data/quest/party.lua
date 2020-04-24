local Chara = require("api.Chara")
local Rand = require("api.Rand")

local party = {
   _id = "party",
   _type = "elona_sys.quest",

   elona_id = 1009,
   ordering = 50000,
   client_chara_type = 7,
   reward = nil,
   reward_fix = 0,

   min_fame = 0,
   chance = function(client, town)
      if town.gen_id == "elona.palmia" then
         return 8
      end

      return 23
   end,

   params = { required_points = "number" },

   difficulty = function()
      local performer_skill = Chara.player():skill_level("elona.performer")
      return math.clamp(Rand.rnd(performer_skill + 10),
                        math.floor(1.5 * math.sqrt(performer_skill)) + 1,
                        math.floor(Chara.player():calc("fame") / 1000) + 10)
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   locale_data = function(self)
      return { required_points = self.params.required_points }
   end
}

function party.generate(self, client)
   self.params = {
      required_points = self.difficulty * 10 + Rand.rnd(50)
   }

   return true
end

-- data:add(party)
