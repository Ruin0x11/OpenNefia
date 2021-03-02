local Gui = require("api.Gui")
local Chara = require("api.Chara")
local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Rand = require("api.Rand")
local Item = require("api.Item")
local Skill = require("mod.elona_sys.api.Skill")
local Log = require("api.Log")
local World = require("api.World")
local I18N = require("api.I18N")
local Const = require("api.Const")

local Hunger = {}

function Hunger.food_name(food_type, original_name, food_quality, chara_id)
   -- >>>>>>>> shade2/text.hsp:531 #defcfunc foodName int type,str sRef,int lv,int su ...
   local origin = original_name

   local food_type_proto = data["elona.food_type"][food_type]
   if food_type_proto and food_type_proto.uses_chara_name and chara_id == nil then
      origin = nil
   end

   if origin == nil then
      origin = I18N.get("food.names." .. food_type .. ".default_origin")
   end

   if chara_id then
      origin = I18N.get("chara." .. chara_id .. ".name")
   end
   print(origin, food_type, food_quality)

   return I18N.get("food.names." .. food_type .. "._" .. food_quality, origin)
   -- <<<<<<<< shade2/text.hsp:641 	return s ..
end

function Hunger.get_food_image(food_type, food_quality)
   -- >>>>>>>> shade2/text.hsp:645 *item_foodInit ..
   local entry = data["elona.food_type"]:ensure(food_type)

   local image = entry.item_chips[food_quality]

   if not image then
      Log.warn("Missing food image for cooked food quality %d", food_quality)
      image = "elona.item_dish_charred"
   end

   return image
   -- <<<<<<<< shade2/text.hsp:655 	return ...
end

function Hunger.make_dish(item, quality)
   -- >>>>>>>> shade2/item_func.hsp:705 #deffunc make_dish int ci,int p ..
   local food_type = item.params and item.params.food_type
   if not food_type then
      Log.warn("'%s' isn't a cookable food.", item._id)
      return nil
   end

   item.image = Hunger.get_food_image(food_type, quality)
   print("setimage", item.image)
   item.weight = 500
   if item.spoilage_date and item.spoilage_date >= 0 then
      item.spoilage_date = 72 + World.date_hours()
   end
   item.params.food_quality = quality

   return item
   -- <<<<<<<< shade2/item_func.hsp:709 	return ..
end

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

function Hunger.proc_anorexia(chara)
   if chara:calc("is_anorexic") then
      Hunger.vomit(chara)
      return true
   end
   return false
end

function Hunger.cure_anorexia(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1884 #deffunc cure_anorexia int c ...
   if not chara.is_anorexic then
      return false
   end

   chara.is_anorexic = false
   if chara:is_in_fov() or chara:is_in_player_party() then
      Gui.mes("food.anorexia.recovers_from", chara)
      Gui.mes("base.offer1", chara.x, chara.y)
   end

   return true
   -- <<<<<<<< shade2/chara_func.hsp:1888 	return ..
end

-- TODO externalize?
local stat_to_food_buff = {
   ["elona.stat_strength"] = "elona.food_str",
   ["elona.stat_constitution"] = "elona.food_end",
   ["elona.stat_dexterity"] = "elona.food_dex",
   ["elona.stat_perception"] = "elona.food_per",
   ["elona.stat_learning"] = "elona.food_ler",
   ["elona.stat_will"] = "elona.food_wil",
   ["elona.stat_magic"] = "elona.food_mag",
   ["elona.stat_charisma"] = "elona.food_chr",
   ["elona.stat_speed"] = "elona.food_spd",
}
local food_buff_to_stat = {}
for k, v in pairs(stat_to_food_buff) do
   food_buff_to_stat[v] = k
end

function Hunger.vomit(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1890 #deffunc chara_vomit int c ...
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

   local function is_food_buff(buff)
      return not not food_buff_to_stat[buff._id]
   end

   for i, buff in chara:iter_buffs():filter(is_food_buff) do
      assert(chara:remove_buff(i))
   end

   local map = chara:current_map()
   if not map:has_type("world_map") then
      local chance = 2
      for _, item in Item.iter_ground(map) do
         if Item.is_alive(item) and item._id == "elona.vomit" then
            chance = chance + 1
         end
      end
      if chara:is_player() or Rand.one_in(chance ^ 3) then
         local vomit = Item.create("elona.vomit", chara.x, chara.y)
         if vomit and not chara:is_player() then
            vomit.params.chara_id = chara._id
         end
      end
   end

   if chara:calc("is_anorexic") then
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
               Gui.play_sound("base.offer1", chara.x, chara.y)
            end
         end
      end
   end

   chara:apply_effect("elona.dimming", 100)
   Effect.modify_weight(chara, (1 + Rand.rnd(5)) * -1)

   if chara.nutrition <= 0 then
      chara:damage_hp(9999, "elona.hunger")
   end

   chara.nutrition = chara.nutrition - 3000
   -- <<<<<<<< shade2/chara_func.hsp:1927 	return ..
end

function Hunger.add_rotten_food_exp_losses(chara, exp_gains)
   exp_gains = exp_gains or {}

   return exp_gains
end

function Hunger.is_human_flesh(food)
   if food._id == "elona.corpse" then
      local chara_proto = data["base.chara"]:ensure(food.params.chara_id)
      if table.index_of(chara_proto.tags, "man") then
         return true
      end
   end
   return false
end

local function show_player_eating_message(player, food)
   -- >>>>>>>> shade2/item.hsp:919 		p=iParam1(ci)/extFood ...
   local food_quality = food.params.food_quality or 0
   local is_rotten = food.spoilage_date and food.spoilage_date < World.date_hours()

   if player:has_trait("elona.eat_human") then
      if Hunger.is_human_flesh(food) then
         Gui.mes("food.effect.human.delicious")
      end

      if is_rotten then
         Gui.mes("food.effect.rotten")
         return
      end

      if food_quality <= 0 then
         local food_type = food.params.food_type
         if food_type then
            local message = I18N.get_optional("food.names.elona.meat.uncooked_message")
            if message then
               Gui.mes(message)
               return
            end

            Gui.mes("food.effect.boring")
            return
         end
      end

      if food_quality < 3 then
         Gui.mes("food.effect.quality.bad")
         return
      end
      if food_quality < 5 then
         Gui.mes("food.effect.quality.so_so")
         return
      end
      if food_quality < 7 then
         Gui.mes("food.effect.quality.good")
         return
      end
      if food_quality < 9 then
         Gui.mes("food.effect.quality.great")
         return
      end

      Gui.mes("food.effect.quality.delicious")
   end
   -- <<<<<<<< shade2/item.hsp:942 		} ..
end

-- >>>>>>>> shade2/item.hsp:765 	#define global maxFoodEffect 10 ...
Hunger.MAX_FOOD_EATING_EFFECTS = 10
-- <<<<<<<< shade2/item.hsp:765 	#define global maxFoodEffect 10 ..

function Hunger.apply_general_eating_effect(chara, food)
   -- >>>>>>>> shade2/item.hsp:833 *eatEffect ...
   local nutrition = 2500
   if food:calc("is_cargo") then
      nutrition = nutrition + 2500
   end

   local exp_gains = {}

   local food_type = food.params.food_type
   if food_type then
      local proto = data["elona.food_type"]:ensure(food_type)

      if proto.exp_gains then
         for _, gain in ipairs(proto.exp_gains) do
            exp_gains[#exp_gains+1] = {
               _id = gain._id,
               amount = gain.amount
            }
         end
      end

      if proto.base_nutrition then
         nutrition = proto.base_nutrition
      end
   end

   local food_quality = food.params.food_quality or 0

   nutrition = nutrition * (100 + food_quality * 15) / 100

   for _, gain in ipairs(exp_gains) do
      if gain.amount > 0 then
         if food_quality < 3 then
            gain.amount = gain.amount / 2
         else
            gain.amount = gain.amount * (50 * food_quality * 20) / 100
         end
      else
         if food_quality < 3 then
            gain.amount = gain.amount * ((3-food_quality) * 100 + 100) / 100
         else
            gain.amount = gain.amount * 100 / (food_quality * 50)
         end
      end
   end

   local is_rotten = food.spoilage_date and food.spoilage_date < World.date_hours()

   if chara:is_player() then
      show_player_eating_message(chara, food)
   else
      if food:calc("material") == "elona.fresh" and is_rotten then
         Gui.mes("food.effect.raw_glum", chara)
      end
   end

   if food.food_exp_gains then
      for _, gain in ipairs(food.food_exp_gains) do
         exp_gains[#exp_gains+1] = {
            _id = gain._id,
            amount = gain.amount
         }
      end
      if food.nutrition then
         nutrition = food.nutrition
      end
   end

   if chara:is_player() and is_rotten then
      exp_gains = Hunger.add_rotten_food_exp_losses(chara, exp_gains)
   end

   local event_result = { nutrition = nutrition, exp_gains = exp_gains }
   food:emit("elona_sys.before_item_eat", {chara=chara}, event_result)
   nutrition = event_result.nutrition or nutrition
   exp_gains = event_result.exp_gains or exp_gains

   for i = 1, Hunger.MAX_FOOD_EATING_EFFECTS do
      local gain = exp_gains[i]
      if gain == nil then
         break
      end

      local power = 100

      if chara.nutrition >= Const.HUNGER_THRESHOLD_NORMAL then
         local factor = (chara.nutrition - Const.HUNGER_THRESHOLD_NORMAL) / 25
         power = power * 100 / (100 + factor)
      end

      if not chara:is_player() then
         power = 1500
         if is_rotten then
            power = 500
         end
      end

      if power > 0 then
         Skill.gain_skill_exp(chara, gain._id, gain.amount * power / 100)
      end
   end

   local curse_state = food:calc("curse_state")

   if curse_state >= Enum.CurseState.Blessed then
      nutrition = nutrition * 150 / 100
   elseif curse_state <= Enum.CurseState.Cursed then
      nutrition = nutrition * 50 / 100
   end

   local force_weight_gain = chara.nutrition >= Const.HUNGER_THRESHOLD_BLOATED
   if nutrition >= 3000 and (Rand.one_in(10) or force_weight_gain) then
      Effect.modify_weight(chara, Rand.rnd(3) + 1, force_weight_gain)
   end

   chara.nutrition = chara.nutrition + nutrition

   food:emit("elona_sys.on_item_eat", {chara=chara,nutrition=nutrition,exp_gains=exp_gains})

   for _, merged_enc in food:iter_merged_enchantments() do
      if merged_enc.proto.on_eat_food then
         merged_enc.proto.on_eat_food(merged_enc.total_power, merged_enc.params, food, chara)
      end
   end

   Hunger.apply_food_curse_state(chara, curse_state)
   -- <<<<<<<< shade2/item.hsp:1206 	return ..
end

function Hunger.eat_food(chara, food)
   -- >>>>>>>> shade2/proc.hsp:1128 *insta_eat ..
   Hunger.apply_general_eating_effect(chara, food)

   if chara:is_player() then
      Effect.identify_item(food, Enum.IdentifyState.Name)
   end

   if chara:unequip_item(food) then
      chara:refresh()
   end

   food:remove(1)

   if chara:is_player() then
      Hunger.show_eating_message(chara)
   else
      local is_eating_traded_item = chara.item_to_use and chara.item_to_use == food
      if is_eating_traded_item then
         chara.item_to_use = nil
      end

      if is_eating_traded_item then
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

   Hunger.proc_anorexia(chara)
   -- <<<<<<<< shade2/proc.hsp:1155 	return ..
end

function Hunger.make_player_hungry(chara)
   -- >>>>>>>> shade2/calculation.hsp:1150 *calcHunger		;hunger (sSurvival) ...
   if chara:has_trait("elona.perm_slow_food") and Rand.one_in(3) then
      return
   end

   local old_level = math.floor(chara.nutrition / 1000)
   chara.nutrition = chara.nutrition - Const.HUNGER_DECREMENT_AMOUNT
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
   -- <<<<<<<< shade2/calculation.hsp:1160 	return ..
end

function Hunger.make_other_hungry(other)
   -- >>>>>>>> shade2/main.hsp:890 		if mType!mTypeWorld:cHunger(cc)-=defHungerDec*2: ...
   local map = other:current_map()
   if not map or map:has_type("world_map") then
      return
   end

   other.nutrition = other.nutrition - Const.HUNGER_DECREMENT_AMOUNT * 2
   if other.nutrition < Const.ALLY_HUNGER_THRESHOLD and not other:calc("is_anorexic") then
      other.nutrition = Const.ALLY_HUNGER_THRESHOLD
   end
   -- <<<<<<<< shade2/main.hsp:890 		if mType!mTypeWorld:cHunger(cc)-=defHungerDec*2: ..
end

return Hunger
