local Chara = require("api.Chara")
local Const = require("api.Const")
local Effect = require("mod.elona.api.Effect")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local RandomEventPrompt = require("api.gui.RandomEventPrompt")
local Skill = require("mod.elona_sys.api.Skill")
local Hunger = require("mod.elona.api.Hunger")
local I18N = require("api.I18N")
local Enum = require("api.Enum")
local Itemgen = require("mod.elona.api.Itemgen")
local Item = require("api.Item")
local Save = require("api.Save")

local SleepEvent = {}

function SleepEvent.can_make_breakfast(chara)
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234110 			if ( cdata(CDATA_EXIST, cnt) != CHAR_STATE_ALIV ...
   return Chara.is_alive(chara)
      and not chara:is_player()
      and chara:calc("impression") >= Const.IMPRESSION_FELLOW
      and Effect.is_visible(chara, Chara.player())
      and chara:has_skill("elona.cooking")
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234131 			} ..
end

function SleepEvent.find_ally(pred)
   local main = nil
   local allies = Chara.iter_allies():filter(pred):to_list()
   for _, chara in ipairs(allies) do
      -- TODO plus_items
      -- and not chara:find_item("plus_items.pleasant_sleep_blanket")
      if main == nil then
         main = chara
      elseif Rand.one_in(2) then
         main = chara
      end
   end
   return main, allies
end

function SleepEvent.calc_breakfast_quality(main_ally, allies)
   local quality = Rand.rnd(main_ally:skill_level("elona.cooking") + 2)
   for _, ally in ipairs(allies) do
      if ally ~= main_ally then
         quality = quality + Rand.rnd(ally:skill_level("elona.cooking") / 2 + 2)
      end
   end
   return quality
end

function SleepEvent.calc_breakfast_potential_growth(food_quality)
   if food_quality <= 0 then
      return 1
   elseif food_quality >= 1 and food_quality <= 10 then
      return 2
   elseif food_quality >= 11 and food_quality <= 20 then
      return 3
   elseif food_quality >= 21 and food_quality <= 40 then
      return 4
   elseif food_quality >= 41 and food_quality <= 60 then
      return 5
   else
      return 6
   end
end

function SleepEvent.show_breakfast_eating_message(food_quality)
   if food_quality <= 0 then
      Gui.mes("food.effect.uncooked_message")
   elseif food_quality >= 1 and food_quality <= 10 then
      Gui.mes("food.effect.quality.bad")
   elseif food_quality >= 11 and food_quality <= 20 then
      Gui.mes("food.effect.quality.so_so")
   elseif food_quality >= 21 and food_quality <= 40 then
      Gui.mes("food.effect.quality.good")
   elseif food_quality >= 41 and food_quality <= 60 then
      Gui.mes("food.effect.quality.great")
   else
      Gui.mes("food.effect.quality.delicious")
   end
end

function SleepEvent.apply_breakfast_eating_effect(chara, growth, quality)
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234214 				cdata(CDATA_HUNGER, cnt) = 12000 ...
   chara.nutrition = 12000
   -- chara.thirst = 12000
   if not Chara.is_alive(chara) then
      return
   end
   for _, skill_id in Skill.iter_attributes() do
      Skill.modify_potential(chara, skill_id, growth)
   end
   Hunger.proc_anorexia(chara)
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234229 				chara_anorexia cnt ..
end

function SleepEvent.breakfast()
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234106 		_switch_sw = 0 ...
   local main_ally, allies = SleepEvent.find_ally(SleepEvent.can_make_breakfast)
   if not Chara.is_alive(main_ally) then
      return false
   end

   Gui.play_sound("base.chat")
   Gui.wait(400)
   Gui.play_sound("base.chat")
   -- TODO custom talk
   if true then
      Gui.mes_c("plus:talk.sleep_event.breakfast", "SkyBlue", main_ally)
   end

   local text
   if #allies == 1 then
      text = "plus:sleep_event.breakfast.event.text.one"
   else
      text = "plus:sleep_event.breakfast.event.text.multiple"
   end

   if main_ally:has_base_skill("elona.cooking") then
      Skill.gain_skill_exp(main_ally, "elona.cooking", 1000)
   end

   local prompt = RandomEventPrompt:new(
      "plus:sleep_event.breakfast.event.title",
      I18N.get(text, main_ally),
      "base.bg_re10",
      {
         "plus:sleep_event.breakfast.event.choices._1",
         "plus:sleep_event.breakfast.event.choices._2",
   })

   local index = prompt:query()

   if index == 1 then
      Gui.play_sound("base.eat1")
      Gui.wait(500)
      Gui.play_sound("base.offer2")

      local quality = SleepEvent.calc_breakfast_quality(main_ally, allies)
      quality = math.max(math.floor(quality), 0)
      for _, ally in ipairs(allies) do
         if ally:has_base_skill("elona.cooking") then
            Skill.gain_skill_exp(ally, "elona.cooking", 500)
         end
      end
      SleepEvent.show_breakfast_eating_message(quality)
      local growth = SleepEvent.calc_breakfast_potential_growth(quality)
      for _, ally in Chara.iter_allies() do
         SleepEvent.apply_breakfast_eating_effect(ally, growth, quality)
      end
      return true
   else
      Gui.play_sound("base.atk_dark")
      main_ally:set_emotion_icon("elona.fear", 3)
      Gui.mes_c("plus:sleep_event.breakfast.rejected", "Purple", main_ally)
      return false
   end
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234242 	} ..
end

function SleepEvent.can_handmake_gift(chara)
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234251 			if ( cdata(CDATA_EXIST, cnt) != CHAR_STATE_ALIV ...
   return Chara.is_alive(chara)
      and not chara:is_player()
      and chara:calc("impression") >= Const.IMPRESSION_MARRY
      and Effect.is_visible(chara, Chara.player())
      and chara:has_skill("elona.carpentry")
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234272 			} ..
end

function SleepEvent.calc_handmade_gift_quality(main_ally, allies)
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234291 		cre2 = rnd(sdata(SKILL_NORMAL_CARPENTRY, tc) + 1 ...
   local quality = Rand.rnd(main_ally:skill_level("elona.carpentry") + 10) + 1
   for _, ally in ipairs(allies) do
      if ally ~= main_ally then
         quality = quality + Rand.rnd(ally:skill_level("elona.carpentry") / 2 + 5) + 1
      end
   end
   return quality
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234309 		loop ..
end

function SleepEvent.random_handmade_gift_item_id(quality)
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234323 			p = ITEM_ID_ROUND_SHIELD ...
   local _id = "elona.round_shield"
   if quality >= 20 then
      _id = "elona.knight_helm"
   elseif quality >= 30 then
      _id = "elona.neck_guard"
   elseif quality >= 40 then
      _id = "elona.plate_girdle"
   elseif quality >= 50 then
      _id = "elona.chain_mail"
   elseif quality >= 60 then
      _id = "elona.armored_boots"
   elseif quality >= 70 then
      _id = "elona.tower_shield"
   elseif quality >= 80 then
      _id = "elona.composite_helm"
   elseif quality >= 90 then
      _id = "elona.plate_gauntlets"
   elseif quality >= 100 then
      _id = "elona.plate_mail"
   end
   return _id
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234350 			} ..
end

function SleepEvent.create_gift(player, main_ally, _id)
   local quality
   if player:skill_level("elona.stat_luck") + main_ally:calc("impression") * 2 > Rand.rnd(10000) then
      quality = Enum.Quality.God
   else
      quality = Enum.Quality.Great
   end

   local filter = {
      level = 100,
      quality = quality,
      no_stack = true,
      no_oracle = true
   }

   local item = Item.create(_id, player.x, player.y, filter, player:current_map())
   if item then
      item.curse_state = Enum.CurseState.Blessed
   end

   return item
end

function SleepEvent.handmade_gift()
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234244 		_switch_sw = 0 ...
   if Chara.player():has_effect("elona.blindness") then
      return false
   end

   local main_ally, allies = SleepEvent.find_ally(SleepEvent.can_handmake_gift)
   if not Chara.is_alive(main_ally) then
      return false
   end

   Gui.play_sound("base.chat")
   Gui.wait(400)
   Gui.play_sound("base.chat")
   -- TODO custom talk
   if true then
      Gui.mes_c("plus:talk.sleep_event.handmade_gift", "SkyBlue", main_ally)
   end

   local text
   if #allies == 1 then
      text = "plus:sleep_event.handmade_gift.event.text.one"
   else
      text = "plus:sleep_event.handmade_gift.event.text.multiple"
   end

   if main_ally:has_base_skill("elona.carpentry") then
      Skill.gain_skill_exp(main_ally, "elona.carpentry", 1000)
   end

   local quality = SleepEvent.calc_handmade_gift_quality(main_ally, allies)
   for _, ally in ipairs(allies) do
      if ally:has_base_skill("elona.carpentry") then
         Skill.gain_skill_exp(ally, "elona.carpentry", 500)
      end
   end

   local prompt = RandomEventPrompt:new(
      "plus:sleep_event.handmade_gift.event.title",
      I18N.get(text, main_ally),
      "base.bg_re3",
      {
         "plus:sleep_event.handmade_gift.event.choices._1",
         "plus:sleep_event.handmade_gift.event.choices._2",
   })

   local index = prompt:query()

   if index == 1 then
      local _id = SleepEvent.random_handmade_gift_item_id(quality)
      local item = SleepEvent.create_gift(Chara.player(), main_ally, _id)
      if item then
         Gui.mes("common.something_is_put_on_the_ground")
      end
      main_ally:set_emotion_icon("elona.happy", 3)
      Gui.mes("plus:sleep_event.handmade_gift.accepted", main_ally)
      Save.queue_autosave()
      return true
   else
      Gui.play_sound("base.atk_dark", main_ally.x, main_ally.y)
      main_ally:set_emotion_icon("elona.fear", 3)
      Gui.mes_c("plus:sleep_event.handmade_gift.rejected", "Purple", main_ally)
      return false
   end
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234377 		goto *random_eventProc_SWEND1 ..
end

function SleepEvent.can_handknit_gift(chara)
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234251 			if ( cdata(CDATA_EXIST, cnt) != CHAR_STATE_ALIV ...
   return Chara.is_alive(chara)
      and not chara:is_player()
      and chara:calc("impression") >= Const.IMPRESSION_MARRY
      and Effect.is_visible(chara, Chara.player())
      and chara:has_skill("elona.tailoring")
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234272 			} ..
end

function SleepEvent.calc_handknitted_gift_quality(main_ally, allies)
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234291 		cre2 = rnd(sdata(SKILL_NORMAL_CARPENTRY, tc) + 1 ...
   local quality = Rand.rnd(main_ally:skill_level("elona.tailoring") + 10) + 1
   for _, ally in ipairs(allies) do
      if ally ~= main_ally then
         quality = quality + Rand.rnd(ally:skill_level("elona.tailoring") / 2 + 5) + 1
      end
   end
   return quality
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234309 		loop ..
end

function SleepEvent.random_handknitted_gift_item_id(quality)
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234323 			p = ITEM_ID_ROUND_SHIELD ...
   local _id = "elona.gloves"
   if quality >= 20 then
      _id = "elona.tight_boots"
   elseif quality >= 30 then
      _id = "elona.coat"
   elseif quality >= 40 then
      _id = "elona.magic_hat"
   elseif quality >= 50 then
      _id = "elona.light_cloak"
   elseif quality >= 60 then
      _id = "elona.cloak"
   elseif quality >= 70 then
      _id = "elona.decorated_gloves"
   elseif quality >= 80 then
      _id = "elona.pope_robe"
   elseif quality >= 90 then
      _id = "elona.bulletproof_jacket"
   elseif quality >= 100 then
      _id = "elona.fairy_hat"
   end
   return _id
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234350 			} ..
end

function SleepEvent.handknitted_gift()
   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:234244 		_switch_sw = 0 ...
   if Chara.player():has_effect("elona.blindness") then
      return false
   end

   local main_ally, allies = SleepEvent.find_ally(SleepEvent.can_handknit_gift)
   if not Chara.is_alive(main_ally) then
      return false
   end

   Gui.play_sound("base.chat")
   Gui.wait(400)
   Gui.play_sound("base.chat")
   -- TODO custom talk
   if true then
      Gui.mes_c("plus:talk.sleep_event.handknitted_gift", "SkyBlue", main_ally)
   end

   local text
   if #allies == 1 then
      text = "plus:sleep_event.handknitted_gift.event.text.one"
   else
      text = "plus:sleep_event.handknitted_gift.event.text.multiple"
   end

   if main_ally:has_base_skill("elona.tailoring") then
      Skill.gain_skill_exp(main_ally, "elona.tailoring", 1000)
   end

   local quality = SleepEvent.calc_handknitted_gift_quality(main_ally, allies)
   for _, ally in ipairs(allies) do
      if ally:has_base_skill("elona.tailoring") then
         Skill.gain_skill_exp(ally, "elona.tailoring", 500)
      end
   end

   local prompt = RandomEventPrompt:new(
      "plus:sleep_event.handknitted_gift.event.title",
      I18N.get(text, main_ally),
      "base.bg_re14",
      {
         "plus:sleep_event.handknitted_gift.event.choices._1",
         "plus:sleep_event.handknitted_gift.event.choices._2",
   })

   local index = prompt:query()

   if index == 1 then
      local _id = SleepEvent.random_handknitted_gift_item_id(quality)
      local item = SleepEvent.create_gift(Chara.player(), main_ally, _id)
      if item then
         Gui.mes("common.something_is_put_on_the_ground")
      end
      main_ally:set_emotion_icon("elona.happy", 3)
      Gui.mes("plus:sleep_event.handknitted_gift.accepted", main_ally)
      Save.queue_autosave()
      return true
   else
      -- TODO plus sounds
      Gui.play_sound("plus.stab", main_ally.x, main_ally.y)
      main_ally:set_emotion_icon("elona.fear", 3)
      Gui.mes_c("plus:sleep_event.handknitted_gift.rejected", "Purple", main_ally)
      return false
   end
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:234377 		goto *random_eventProc_SWEND1 ..
end

return SleepEvent
