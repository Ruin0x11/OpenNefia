local Rand = require("api.Rand")
local I18N = require("api.I18N")

local cook = {
   _id = "cook",
   _type = "elona_sys.quest",

   elona_id = 1003,
   ordering = 90000,
   client_chara_type = 3,
   reward = "elona.supply",
   reward_fix = 60,

   min_fame = 0,
   chance = 6,

   params = {
      food_type = "number",
      food_quality = "number"
   },

   difficulty = 0,

   expiration_hours = function() return (Rand.rnd(3) + 1) * 24 end,
   deadline_days = function() return Rand.rnd(6) + 2 end,

   locale_data = function(self)
      local ingredient = "food.names._" .. self.params.food_type .. ".default_origin"
      local objective = I18N.get("food.names._" .. self.params.food_type .. "._" .. self.params.food_quality, ingredient)
      local params = { objective = objective }
      local key = "food_type._" .. self.params.food_type
      return params, key
   end
}

function cook.generate(self, client, start)
   local food_type = Rand.rnd(8) + 1

   local category

   if food_type == 4 then
      category = "elona.drink"
   elseif food_type == 6 then
      category = "elona.equip_ammo"
   elseif food_type == 1 then
      category = "elona.equip_ammo"
   elseif food_type == 5 then
      category = "elona.drink"
   elseif food_type == 7 then
      category = "elona.ore"
   elseif food_type == 2 then
      category = "elona.rod"
   elseif food_type == 3 then
      category = "elona.scroll"
   end

   if category then
      self.reward = { _id = "elona.by_category", category = category }
   else
      self.reward = { _id = "elona.supply" }
   end

   local food_quality = Rand.rnd(7) + 3
   self.difficulty = food_quality * 3
   self.reward_fix = 60 + self.difficulty

   self.params = {
      food_type = food_type,
      food_quality = food_quality
   }

   return true
end

data:add(cook)
