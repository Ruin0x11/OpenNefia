local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Ui = require("api.Ui")
local I18N = require("api.I18N")

local harvest = {
   _id = "harvest",
   _type = "elona_sys.quest",

   elona_id = 1006,
   ordering = 60000,
   client_chara_type = 5,
   reward = "elona.supply",
   reward_fix = 60,

   min_fame = 0,
   chance = function(client, town)
      if town.gen_id == "elona.yowyn" then
         return 2
      end

      return 30
   end,

   params = { required_weight = "number", current_weight = "number" },

   difficulty = function()
      return math.clamp(Rand.rnd(Chara.player():calc("level") + 5) +
                           Rand.rnd(Chara.player():calc("fame") / 800 + 1) + 1,
                        1, 50)
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   generate = function(self, client)
      self.reward_fix = 60 + self.difficulty * 2

      self.params = {
         required_weight = 15000 + self.difficulty * 2500,
         current_weight = 0
      }

      return true
   end,

   locale_data = function(self, is_active)
      local required_weight = Ui.display_weight(self.params.required_weight)
      local objective = I18N.get("quest.info.harvest.text", required_weight)
      if is_active then
         objective = objective .. I18N.get("quest.info.now", Ui.display_weight(self.params.current_weight))
      end

      return {
         objective = objective
      }
   end
}
data:add(harvest)
