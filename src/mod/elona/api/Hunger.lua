local Gui = require("api.Gui")
local Skill = require("mod.elona_sys.api.Skill")

local Hunger = {}

local lists = {
   [1] = {
      nutrition = 3500,
      { id = 10, power = 30 },
      { id = 11, power = 40 },
      { id = 17, power = 10 },
   },
   [8] = {
      nutrition = 2000,
      { id = 17, power = 20 },
      { id = 13, power = 20 },
      { id = 15, power = 20 },
   },
   [2] = {
      nutrition = 2000,
      { id = 14, power = 50 },
   },
   [3] = {
      nutrition = 2000,
      { id = 16, power = 50 },
      { id = 17, power = 20 },
      { id = 13, power = 30 },
   },
   [7] = {
      nutrition = 2800,
      { id = 10, power = 25 },
      { id = 12, power = 25 },
      { id = 14, power = 25 },
      { id = 11, power = 25 },
   },
   [4] = {
      nutrition = 1500,
      { id = 16, power = 40 },
      { id = 12, power = 30 },
      { id = 14, power = 30 },
   },
   [6] = {
      nutrition = 3000,
      { id = 14, power = 40 },
      { id = 12, power = 40 },
      { id = 13, power = 20 },
   },
   [5] = {
      nutrition = 3500,
      { id = 11, power = 60 },
      { id = 12, power = 40 },
   },
}

function Hunger.calc_base_food_buff(power, food_quality)
   if power > 0 then
      if food_quality < 3 then
         power = math.floor(power/2)
      else
         power = power * (50 + food_quality * 20) / 100
      end
   elseif food_quality < 3 then
      power = power * ((3 - food_quality) * 100 + 100) / 100
   else
      power = power * 100 / (food_quality * 50)
   end
   return power
end

function Hunger.calc_base_nutrition(item)
   local buffs = {}
   local quality = item:calc("food_quality") or item:calc("food_rank") or 0

   for _, v in ipairs(item:calc("base_food_buffs") or lists[1]) do
      local power = v.power
      if not v.no_modify then
         Hunger.calc_base_food_buff(v.power, quality)
      end
      buffs[#buffs+1] = { id = v.id, power = power }
   end

   return buffs
end

function Hunger.apply_food_buffs(chara, buffs, is_rotten)
   for _, buff in ipairs(buffs) do
      local i = 1000
      local nutrition = chara:calc("nutrition")

      if nutrition >= 5000 then
         local p = math.floor(nutrition - 5000 / 25)
         i = math.floor(i * 100 / (100 + p))
      end
      if not chara:is_player() then
         i = 1500
         if is_rotten then
            i = 500
         end
      end
      if i > 0 then
         Skill.gain_skill_exp(chara, buff.id, buff.power * i / 100)
      end
   end
end

function Hunger.calc_nutrition(item)
   local curse_state = item:calc("curse_state")
   local quality = item:calc("food_quality") or item:calc("food_rank") or 0

   local nutrition = item:calc("base_nutrition") or 2500

   local apply_nutrition_buff = item:has_type("elona.food")
   if apply_nutrition_buff then
      nutrition = nutrition * (100 + quality * 15) / 100
   end

   local override_nutrition = item:calc("nutrition")
   if override_nutrition then
      nutrition = override_nutrition
   end

   if curse_state == "blessed" then
      nutrition = nutrition * 150 / 100
   end
   if curse_state == "cursed" or curse_state == "doomed" then
      nutrition = nutrition * 50 / 100
   end

   return nutrition
end

function Hunger.print_quality(chara, item)
   if chara:is_player() then
      local quality = item:calc("food_quality") or item:calc("food_rank") or 0
      if chara:has_trait("elona.eat_human") then
         local is_human = item._id == "elona.corpse" and false
         if is_human then
            Gui.mes("food: human flesh")
            return
         end
      end

      if item.material == "elona.raw" and item:calc("time_until_rot") < 0 then
         Gui.mes("food: rotten")
         return
      end

      if quality <= 0 then
         -- TODO raw meat/powder/raw
         return
      end
      if quality < 3 then
         Gui.mes("food: bad")
         return
      end
      if quality < 5 then
         Gui.mes("food: so_so")
         return
      end
      if quality < 7 then
         Gui.mes("food: good")
         return
      end
      if quality < 9 then
         Gui.mes("food: good")
         return
      end

      Gui.mes("food: delicious")

   elseif item.material == "elona.raw" and item:calc("time_until_rot") < 0 then
      Gui.mes("food other: rotten")
      return
   end
end

return Hunger
