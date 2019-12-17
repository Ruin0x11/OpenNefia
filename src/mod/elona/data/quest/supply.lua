local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.tools.api.Itemgen")
local I18N = require("api.I18N")

local supply = {
   _id = "supply",
   _type = "elona_sys.quest",

   elona_id = 1004,
   ordering = 100000,
   client_chara_type = 3,
   reward = "elona.supply",
   reward_fix = 65,

   min_fame = 0,
   chance = 5,

   params = {
      target_item_id = "string"
   },

   difficulty = function() return math.clamp(Rand.rnd(Chara.player():calc("level") + 5) + 1, 1, 30) end,

   expiration_hours = function() return (Rand.rnd(3) + 1) * 24 end,
   deadline_days = function() return Rand.rnd(6) + 2 end,

   locale_data = function(self)
      return {
         objective = I18N.get("item." .. self.params.target_item_id .. ".name"),
      }
   end
}

function supply.generate(self, client, start)
   local category = Rand.choice(Filters.fsetsupply)
   local item_id = Itemgen.random_item_id_raw(nil, {category})
   assert(item_id)

   self.reward_fix = self.reward_fix + self.difficulty

   self.params = {
      target_item_id = item_id,
   }

   return true
end

data:add(supply)
