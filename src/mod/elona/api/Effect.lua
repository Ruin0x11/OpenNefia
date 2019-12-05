local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Anim = require("mod.elona_sys.api.Anim")
local Skill = require("mod.elona_sys.api.Skill")

local Effect = {}

function Effect.is_cursed(curse_state)
   return curse_state == "cursed" or curse_state == "doomed"
end

function Effect.impregnate(chara)
   if chara:has_enchantment("elona.prevents_pregnancy") then
      Gui.mes("misc.pregnant.pukes_out", chara)
      return false
   end

   if chara.is_pregnant then
      return false
   end

   Gui.mes_c("misc.pregnant.gets_pregnant", "Orange", chara)
   local anim = Anim.load("elona.anim_smoke", chara.x, chara.y)
   Gui.start_draw_callback(anim)
   chara.is_pregnant = true

   return true
end

function Effect.modify_weight(chara, delta, force)
   local height = chara.height
   local min = height * height * 18 / 25000
   local max = height * height * 24 / 10000

   if chara.weight < min then
      chara.weight = min
      return
   end
   if delta > 0 and chara.weight > max and not force then
      return
   end

   chara.weight = math.floor(chara.weight * (100 + delta) / 100 + ((delta > 0 and 1) or 0) - ((delta < 0 and 1) or 0))

   if chara.weight < 1 then
      chara.weight = 1
   end

   if chara:is_in_fov() then
      if delta >= 3 then
         Gui.mes("chara.weight.gain", chara)
      elseif delta <= -3 then
         Gui.mes("chara.weight.lose", chara)
      end
   end
end

function Effect.modify_height(chara, delta)
   chara.height = math.floor(chara.height * (100 + delta) / 100 + ((delta > 0 and 1) or 0) - ((delta < 0 and 1) or 0))

   if chara.height < 1 then
      chara.height = 1
   end

   if chara:is_in_fov() then
      if delta > 0 then
         Gui.mes("chara.height.gain", chara)
      elseif delta < 0 then
         Gui.mes("chara.height.lose", chara)
      end
   end
end

function Effect.show_eating_message(chara)
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

function Effect.apply_food_curse_state(chara, curse_state)
   if not Chara.is_alive(chara) then
      return
   end

   if Effect.is_cursed(curse_state) then
      chara.nutrition = chara.nutrition - 1500
      if chara:is_in_fov() then
         Gui.mes("food.eat_status.bad", chara)
      end
      Effect.vomit(chara)
   elseif curse_state == "blessed" then
      if chara:is_in_fov() then
         Gui.mes("food.eat_status.good", chara)
      end
      if Rand.one_in(5) then
      end

      chara:add_effect_turns("elona.insanity", -2)
   end
end

function Effect.vomit(chara)
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
      if (chara:is_allied() and chara.anorexia_count > 10)
         or (not chara:is_allied() and Rand.one_in(4))
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

function Effect.proc_anorexia(chara)
   if chara:calc("is_anorexic") then
      Effect.vomit(chara)
   end
end

function Effect.proc_cursed_drink(chara, curse_state)
   if not Effect.is_cursed(curse_state) then
      return
   end
   if chara:is_in_fov() then
      Gui.mes("food.eat_status.cursed_drink", chara)
   end
   chara:apply_effect("elona.sick", 200)
end

function Effect.get_hungry(chara)
   if chara:has_trait("elona.slow_digestion") and Rand.one_in(3) then
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

return Effect
