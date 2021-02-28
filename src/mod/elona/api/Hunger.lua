local Gui = require("api.Gui")
local Chara = require("api.Chara")
local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Rand = require("api.Rand")
local Item = require("api.Item")
local Skill = require("mod.elona_sys.api.Skill")
local Log = require("api.Log")
local World = require("api.World")

local Hunger = {}

function Hunger.show_eating_message(chara)
   local nutrition = chara.nutrition
   if nutrition >= 12000 then
      Gui.mes_c("food.eating_message.bloated", "Green")
   elseif nutrition >= 10000 then
      Gui.mes_c("food.eating_message.satisfied", "Green")
   elseif nutrition >= 5000 then
      Gui.mes_c("food.eating_message.normal", "Green")
   elseif nutrition >= 2000 then
      Gui.mes_c("food.eating_message.hungry", "Green")
   elseif nutrition >= 1000 then
      Gui.mes_c("food.eating_message.very_hungry", "Green")
   else
      Gui.mes_c("food.eating_message.starving", "Green")
   end
end

function Hunger.apply_food_curse_state(chara, curse_state)
   -- >>>>>>>> shade2/chara_func.hsp:1930 	if cExist(c)!cAlive:return ..
   if not Chara.is_alive(chara) then
      return
   end

   if Effect.is_cursed(curse_state) then
      chara.nutrition = chara.nutrition - 1500
      if chara:is_in_fov() then
         Gui.mes("food.eat_status.bad", chara)
      end
      Hunger.vomit(chara)
   elseif curse_state == Enum.CurseState.Blessed then
      if chara:is_in_fov() then
         Gui.mes("food.eat_status.good", chara)
      end
      if Rand.one_in(5) then
         Effect.add_buff(chara, chara, "elona.lucky", 100, 500 + Rand.rnd(500))
      end

      Effect.heal_insanity(chara, 2)
   end
   -- <<<<<<<< shade2/chara_func.hsp:1941 	return ..
end

function Effect.proc_anorexia(chara)
   if chara:calc("is_anorexic") then
      Hunger.vomit(chara)
   end
end

function Hunger.vomit(chara)
   chara.anorexia_count = chara.anorexia_count + 1

   if chara:is_in_fov() then
      Gui.play_sound("base.vomit")
      Gui.mes("food.vomits", chara)
   end

   if chara.is_pregnant then
      chara.is_pregnant = false
      if chara:is_in_fov() then
         Gui.mes("food.spits_alien_children", chara)
      end
   end

   local map = chara:current_map()
   if not map:has_type("world_map") then
      local chance = 2
      for _, item in Item.iter_ground(map) do
         if Item.is_alive(item) and item._id == "elona.vomit" then
            chance = chance + 1
         end
      end
      if chara:is_player() or Rand.one_in(chance * chance * chance) then
         local vomit = Item.create("elona.vomit", chara.x, chara.y)
         if vomit and not chara:is_player() then
            vomit.params = { chara_id = chara._id }
         end
      end
   end

   if chara.is_anorexic then
      Skill.gain_fixed_skill_exp(chara, "elona.stat_strength", -50)
      Skill.gain_fixed_skill_exp(chara, "elona.stat_constitution", -75)
      Skill.gain_fixed_skill_exp(chara, "elona.stat_charisma", -100)
   else
      if (chara:is_in_player_party() and chara.anorexia_count > 10)
         or (not chara:is_in_player_party() and Rand.one_in(4))
      then
         if Rand.one_in(5) then
            chara.has_anorexia = true
            if chara:is_in_fov() then
               Gui.mes("food.anorexia.develops", chara)
               Gui.play_sound("base.offer1")
            end
         end
      end
   end

   chara:apply_effect("elona.dimming", 100)
   Effect.modify_weight(chara, (1 + Rand.rnd(5)) * -1)
   if chara.nutrition <= 0 then
      chara:damage_hp(9999, "elona.vomit")
   end
   chara.nutrition = chara.nutrition - 3000
end

function Hunger.eat_rotten_food(chara)
   Log.warn("TODO rotten")
end

function Hunger.get_hungry(chara)
   if chara:has_trait("elona.perm_slow_food") and Rand.one_in(3) then
      return
   end

   local old_level = math.floor(chara.nutrition / 1000)
   chara.nutrition = chara.nutrition - 8
   local new_level = math.floor(chara.nutrition / 1000)
   if new_level ~= old_level then
      if new_level == 1 then
         Gui.mes("food.hunger_status.starving")
      elseif new_level == 2 then
         Gui.mes("food.hunger_status.very_hungry")
      elseif new_level == 5 then
         Gui.mes("food.hunger_status.hungry")
      end
      Skill.refresh_speed(chara)
   end
end

function Hunger.apply_general_eating_effect(chara, food)
   -- >>>>>>>> shade2/item.hsp:833 *eatEffect ...
   -- <<<<<<<< shade2/item.hsp:1206 	return ..
end

function Hunger.eat_food(chara, food)
   -- >>>>>>>> shade2/proc.hsp:1128 *insta_eat ..
   Hunger.apply_general_eating_effect(chara, food)
   food:emit("elona_sys.on_item_eat", {chara=chara})

   if chara:is_player() then
      Effect.identify_item(food, Enum.IdentifyState.Name)
   end

   if chara:unequip_item(food) then
      chara:refresh()
   end

   food.amount = food.amount - 1

   if chara:is_player() then
      Hunger.show_eating_message(chara)
   else
      if chara.item_to_use
         and chara.item_to_use == food
      then
         chara.item_to_use = nil
      end

      if chara.is_eating_traded_item then
         chara.is_eating_traded_item = false
         if food.spoilage_date and food.spoilage_date < World.date_hours() then
            Gui.mes_c("food.passed_rotten", "SkyBlue")
            chara:damage_hp(999, "elona.rotten_food")
            local player = Chara.player()
            if not Chara.is_alive(chara) and chara:relation_towards() > Enum.Relation.Neutral then
               Effect.modify_karma(player, -5)
            else
               Effect.modify_karma(player, -1)
            end
            Skill.modify_impression(chara, -25)
            return
         end
      end
   end

   Effect.proc_anorexia(chara)

   food:emit("elona.on_eat_item_finish", {chara=chara})
   -- <<<<<<<< shade2/proc.hsp:1155 	return ..
end

return Hunger
