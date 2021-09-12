local Event = require("api.Event")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Quest = require("mod.elona_sys.api.Quest")
local Feat = require("api.Feat")
local Anim = require("mod.elona_sys.api.Anim")
local Mef = require("api.Mef")
local UidTracker = require("api.UidTracker")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Log = require("api.Log")
local Input = require("api.Input")
local Skill = require("mod.elona_sys.api.Skill")
local Effect = require("mod.elona.api.Effect")
local Calc = require("mod.elona.api.Calc")
local Chara = require("api.Chara")
local ElonaQuest = require("mod.elona.api.ElonaQuest")
local Enum = require("api.Enum")
local Hunger = require("mod.elona.api.Hunger")
local World = require("api.World")
local Const = require("api.Const")
local ExHelp = require("mod.elona.api.ExHelp")
local SkipList = require("api.SkipList")

--
--
-- turn sequence events
--
--

local function proc_effects_turn_start(chara, params, result)
   local status = nil
   for effect_id, _ in pairs(chara.effects) do
      local effect = data["base.effect"]:ensure(effect_id)
      if effect.on_turn_start then
         local _result, _status = effect.on_turn_start(chara, params, result)
         result = table.merge(result, _result or {})
         status = _status or status
      end
   end
   return result, status
end

Event.register("base.before_chara_turn_start", "Proc effect on_turn_start", proc_effects_turn_start)

local function proc_effects_turn_end(chara, params, result)
   for effect_id, _ in pairs(chara.effects) do
      local effect = data["base.effect"]:ensure(effect_id)
      -- >>>>>>>> shade2/calculation.hsp:1172 #define global emoCon(%1,%2) if %1>0: cEmoIcon(r1) ...
      if effect.emotion_icon then
         chara:set_emotion_icon(effect.emotion_icon)
      end
      -- <<<<<<<< shade2/calculation.hsp:1172 #define global emoCon(%1,%2) if %1>0: cEmoIcon(r1) ..
      -- >>>>>>>> shade2/calculation.hsp:1174 *calcCondition ...
      if effect.on_turn_end then
         result = effect.on_turn_end(chara, params, result) or result
      end
      -- <<<<<<<< shade2/calculation.hsp:1174 *calcCondition ..
   end
   for effect_id, _ in pairs(chara.effects) do
      local effect = data["base.effect"]:ensure(effect_id)
      if effect.auto_heal then
         chara:heal_effect(effect_id, 1)
      end
   end

   return result
end
Event.register("base.on_chara_turn_end", "Proc effect on_turn_end", proc_effects_turn_end, { priority = 110000 })

local function proc_chara_turn_end(chara, params)
   -- >>>>>>>> shade2/main.hsp:880 	if cc=pc{ ...
   if chara:is_player() then
      if chara:calc("inventory_weight_type") >= Enum.Burden.Heavy then
         if Rand.one_in(20) then
            Gui.mes("action.backpack_squashing", chara)
            local damage = chara:calc("max_hp") * (chara:calc("inventory_weight") * 10 / chara:calc("max_inventory_weight") + 10) / 200 + 1
            chara:damage_hp(damage, "elona.burden")
         end
      end

      Hunger.make_player_hungry(chara)
      Skill.refresh_speed(chara)
   else
      Hunger.make_other_hungry(chara)
   end
   -- <<<<<<<< shade2/main.hsp:891 		} ..
end
Event.register("base.on_chara_turn_end", "Proc player burden/hunger/speed", proc_chara_turn_end, { priority = 120000 })

local function init_save()
   local s = save.elona_sys
   s.awake_hours = 0
   s.npc_memory = { killed = {}, generated = {} }
   s.item_memory = { known = {}, generated = {}, reserved = {} }
   s.quest = {
      clients = {},
      towns = {},
      quests = {}
   }
   s.quest_uids = UidTracker:new()
   s.immediate_quest_uid = nil
   s.quest_time_limit = 0
   s.quest_time_limit_notice_interval = 0
   s.sidequest = {}
   s.deferred_events = SkipList:new()
   s.active_main_quests = {}
end

Event.register("base.on_init_save", "Init save (elona_sys)", init_save)

local function show_element_text_damage(target, source, tense, element)
   if element then
      Gui.mes("element.damage." .. element._id, target)
   else
      Gui.mes("element.damage.elona.default", target)
   end
end

local function show_element_text_death(target, source, tense, element)
   if tense == "ally" then
      Gui.mes_continue_sentence()
      local text = I18N.get_optional("element.death." .. element._id .. ".active", target, source)
      if text then
         Gui.mes_c(text, "Red")
      else
         Gui.mes_c("element.death.elona.default.active", "Red", target, source)
      end
   else
      local text = I18N.get_optional("element.death." .. element._id .. ".passive", target, source)
      if text then
         Gui.mes_c(text)
      else
         Gui.mes_c("element.death.elona.default.passive", "Red", target, source)
      end
   end
end

local function show_text_death(target, source, tense)
   -- >>>>>>>> shade2/chara_func.hsp:1603 				p=rnd(4) ...
   local death_type = Rand.rnd(4)

   if tense == "ally" then
      Gui.mes_continue_sentence()

      if death_type == 0 then
         Gui.mes_c("death_by.chara.transformed_into_meat.active", "Red", target, source)
      elseif death_type == 1 then
         Gui.mes_c("death_by.chara.destroyed.active", "Red", target, source)
      elseif death_type == 2 then
         Gui.mes_c("death_by.chara.minced.active", "Red", target, source)
      elseif death_type == 3 then
         Gui.mes_c("death_by.chara.killed.active", "Red", target, source)
      end
   else
      if death_type == 0 then
         Gui.mes_c("death_by.chara.transformed_into_meat.passive", "Red", target, source)
      elseif death_type == 1 then
         Gui.mes_c("death_by.chara.destroyed.passive", "Red", target, source)
      elseif death_type == 2 then
         Gui.mes_c("death_by.chara.minced.passive", "Red", target, source)
      elseif death_type == 3 then
         Gui.mes_c("death_by.chara.killed.passive", "Red", target, source)
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:1608 				} ...
end

local function show_damage_text(chara, weapon, target, damage_level, was_killed,
                                tense, no_attack_text, element, extra_attacks,
                                is_third_person, attack_skill)
   local map = target:current_map()
   if not map:is_in_fov(target.x, target.y) then
      return
   end

   -- >>>>>>>> shade2/action.hsp:1277 		if sync(tc){ ...
   if extra_attacks > 0 then
      Gui.mes("damage.furthermore")
      Gui.mes_continue_sentence()
   end

   local skill = attack_skill or "elona.martial_arts"
   -- <<<<<<<< shade2/action.hsp:1291 			} ...

   local source = chara

   local txt_source = source
   if is_third_person then
      txt_source = nil
   end

   if tense == "ally" and chara then
      if not no_attack_text then
         if weapon then
            -- TODO
            if skill == "elona.throwing" then
               Gui.mes("damage.weapon.attacks_throwing", chara, "damage.weapon." .. skill .. ".verb_and", target, weapon:build_name())
            else
               Gui.mes("damage.weapon.attacks_and", chara, "damage.weapon." .. skill .. ".verb_and", target)
            end
         else
            local melee_style = chara:calc("melee_style") or "default"
            local melee = I18N.get("damage.melee." .. melee_style .. ".enemy")
            Gui.mes("damage.weapon.attacks_unarmed_and", chara, melee, target)
         end
      end

      Gui.mes_continue_sentence()

      if was_killed then
         if element then
            show_element_text_death(target, txt_source, tense, element)
         else
            show_text_death(target, txt_source, tense)
         end
      else
         if damage_level == -1 then
            Gui.mes("damage.levels.scratch", target, txt_source)
         elseif damage_level == 0 then
            Gui.mes_c("damage.levels.slightly", "Yellow", target, txt_source)
         elseif damage_level == 1 then
            Gui.mes_c("damage.levels.moderately", "Orange", target, txt_source)
         elseif damage_level == 2 then
            Gui.mes_c("damage.levels.severely", "Orange", target, txt_source)
         elseif damage_level >= 3 then
            Gui.mes_c("damage.levels.critically", "Red", target, txt_source)
         end
      end
   else
      if not no_attack_text then
         -- TODO dedup, only damage or was_killed text should be shown (?)
         if tense == "enemy" and chara then
            if weapon then
               local weapon_name = I18N.get_optional("damage.weapon." .. skill .. ".name")
               if weapon_name then
                  Gui.mes("damage.weapon.attacks_with", chara, "damage.weapon." .. skill .. ".verb", target, weapon_name)
               end
            else
               local melee_style = chara:calc("melee_style") or "default"
               local melee = I18N.get("damage.melee." .. melee_style .. ".ally")
               Gui.mes("damage.weapon.attacks_unarmed", chara, melee, target)
            end
         end
      end

      if was_killed then
         if element then
            show_element_text_death(target, txt_source, tense, element)
         else
            show_text_death(target, txt_source, tense)
         end
      else
         if target:is_in_fov() then
            if damage_level >= 1 then
               show_element_text_damage(target, txt_source, tense, element)
            else
               if damage_level == 1 then
                  Gui.mes_c("damage.reactions.screams", "Orange", target)
               elseif damage_level == 2 then
                  Gui.mes_c("damage.reactions.writhes_in_pain", "Pink", target)
               elseif damage_level >= 3 then
                  Gui.mes_c("damage.reactions.is_severely_hurt", "Red", target)
               elseif damage_level == -2 then
                  Gui.mes_c("damage.is_healed", "Blue", target)
               end
            end
         end
      end
   end
end
local function get_damage_level(base_damage, damage, chara)
   local damage_level
   if base_damage < 0 then
      damage_level = -2
   elseif damage <= 0 then
      damage_level = -1
   else
      damage_level = math.floor(damage * 6 / chara:calc("max_hp"))
   end
   return damage_level
end
Event.register("base.on_damage_chara", "Damage text and blood", function(chara, params)
                  local damage_level = get_damage_level(params.base_damage, params.damage, chara)

                  if damage_level > 1 then
                     Map.spill_blood(chara.x, chara.y, 1 + Rand.rnd(2))
                  end

                  show_damage_text(params.attacker, params.weapon, chara, damage_level, false,
                                   params.message_tense, params.no_attack_text, params.element, params.extra_attacks,
                                   params.is_third_person, params.attack_skill)

                  -- >>>>>>>> shade2/chara_func.hsp:1534 		rowAct_Check tc ...
                  chara:interrupt_activity()
                  -- <<<<<<<< shade2/chara_func.hsp:1534 		rowAct_Check tc ..

                  -- If an event causes character death, switch to
                  -- passive tense or messages like "kills it. kills
                  -- it. " will print.
                  params.message_tense = "passive"
end, { priority = 50000 })

Event.register("base.on_kill_chara", "Damage text and kill handling", function(chara, params)
                  -- >>>>>>>> shade2/chara_func.hsp:1597 		se=eleInfo(ele,1):if se:snd se,0,1 ..
                  if params.element and params.element.sound then
                     Gui.play_sound(params.element.sound, chara.x, chara.y)
                  end

                  local damage_level = get_damage_level(params.base_damage, params.damage, chara)
                  show_damage_text(params.attacker, params.weapon, chara, damage_level, true,
                                   params.message_tense, params.no_attack_text, params.element, params.extra_attacks,
                                   params.is_third_person, params.attack_skill)

                  if params.element and params.element._id == "elona.nether" and params.attacker and params.damage > 0 then
                     params.attacker:heal_hp(Rand.rnd(params.damage * (200 + params.element_power) / 1000 + 5))
                  end

                  -- This is so the chip will become hidden when the below
                  -- animation is played.
                  --
                  -- BUG: ...but it doesn't work.
                  if config.base.anime_wait > 0 then
                     Gui.update_screen()
                  end

                  if chara:calc("breaks_into_debris") then
                     if chara:is_in_fov() then
                        Gui.play_sound("base.crush1", chara.x, chara.y)
                        local cb = Anim.death(chara.x, chara.y, "base.death_fragments", params.element and params.element._id)
                        Gui.start_draw_callback(cb)
                     end
                     Map.spill_fragments(chara.x, chara.y, 3, chara:current_map())
                  else
                     if chara:is_in_fov() then
                        Gui.play_sound(Rand.choice({"base.kill1", "base.kill2"}), chara.x, chara.y)
                        local cb = Anim.death(chara.x, chara.y, "base.death_blood", params.element and params.element._id)
                        Gui.start_draw_callback(cb)
                     end
                     Map.spill_blood(chara.x, chara.y, 4, chara:current_map())
                  end
                  -- <<<<<<<< shade2/chara_func.hsp:1661 			} ..
end, { priority = 50000 })


Event.register("base.on_chara_killed", "Refresh sidequests (when chara killed)",
               function(chara)
                  local map = chara:current_map()
                  if map then
                     map:emit("elona_sys.on_quest_check")
                  end
               end)

Event.register("base.on_chara_vanquished", "Refresh sidequests (when chara vanquished)",
               function(chara)
                  local map = chara:current_map()
                  if map then
                     map:emit("elona_sys.on_quest_check")
                  end
               end)

Event.register("base.on_map_entered", "Refresh sidequests (when map entered)",
               function(map)
                  map:emit("elona_sys.on_quest_check")
end)

Event.register("base.on_recruited_as_ally", "Refresh sidequests (when ally recruited)",
               function(chara)
                  local map = chara:current_map()
                  if map then
                     map:emit("elona_sys.on_quest_check")
                  end
end)

local function update_buffs(chara, p)
   -- >>>>>>>> shade2/main.hsp:772 	if cBuff(0,cc)!0{ ..
   local remove = {}
   for i = #chara.buffs, 1, -1 do
      local buff = chara.buffs[i]
      buff.duration = buff.duration - 1
      if buff.duration <= 0 then
         remove[#remove+1] = i
      end
   end

   for _, idx in ipairs(remove) do
      local buff = chara.buffs[idx]
      local buff_data = data["elona_sys.buff"]:ensure(buff._id)
      if buff_data.on_expire then
         buff_data.on_expire(buff, chara)
      end
      chara:remove_buff(idx)
   end
   -- <<<<<<<< shade2/main.hsp:782 		} ..
end
Event.register("base.on_chara_pass_turn", "Update character buffs", update_buffs)

local function play_map_music(map)
   local music_id = map:emit("elona_sys.calc_map_music", {}, map.music)
   if music_id and data["base.music"][music_id] then
      Gui.play_music(music_id)
   end
end
Event.register("base.on_map_changed", "Play map music", play_map_music)

local PlayerLightDrawable = require("api.gui.PlayerLightDrawable")
local function add_player_light(player, params)
   if params.previous_player then
      params.previous_player:set_drawable("elona.player_light", nil)
   end

   player:set_drawable("elona.player_light", PlayerLightDrawable:new(), "below", 10000)
end

Event.register("base.on_set_player", "Add player light", add_player_light)

local function warn_quest_abandonment(_, params)
   if Quest.is_immediate_quest_active() then
      Gui.mes("action.move.leave.abandoning_quest")
   end
end
Event.register("elona_sys.before_player_map_leave", "Warn about abandoning instanced quest", warn_quest_abandonment)

local function complete_quest(_, params, result)
   local client = params.talk.speaker
   local quest = Quest.for_client(client)
   if quest and quest.state == "completed" then
      local proto = data["elona_sys.quest"]:ensure(quest._id)

      local next_node = "elona.quest_giver:finish"
      if proto.on_complete then
         next_node = proto.on_complete(quest, client) or next_node
      end

      if params.state.__quest_complete then
         Log.error("Infinite loop detected, did you call Quest.complete() in your dialog?")
         Quest.complete(quest)
      end

      result.node_id = next_node
      params.state.__quest_complete = true
   end
   return result
end
Event.register("elona_sys.on_step_dialog", "If speaker has finished quest, complete it", complete_quest)

local function update_quest_time_limit(_, params)
   local map = Map.current()
   if not map then
      return
   end

   local s = save.elona_sys

   if s.quest_time_limit and s.quest_time_limit > 0 then
      s.quest_time_limit = s.quest_time_limit - params.minutes
      if s.quest_time_limit_notice_interval > math.floor(s.quest_time_limit / 10) then
         Gui.mes_c("quest.minutes_left", "SkyBlue", (s.quest_time_limit + 1))
         s.quest_time_limit_notice_interval = math.floor(s.quest_time_limit / 10)
      end
      if s.quest_time_limit <= 0 then
         s.quest_time_limit = 0
         s.quest_time_limit_notice_interval = 0

         local cb = function()
            local uid = s.immediate_quest_uid
            if not uid then
               Log.error("No immediate quest was set when quest time ran out.")
               return
            end

            local quest = assert(Quest.get(uid))
            local quest_data = data["elona_sys.quest"]:ensure(quest._id)
            if quest_data.on_time_expired then
               quest_data.on_time_expired(quest)
            else
               Log.warn("Time ran out, but immediate quest has no on_time_expired callback.")
            end
         end
         DeferredEvent.add(cb)
      end
   end
end

Event.register("base.on_minute_passed", "Update immediate quest time limit", update_quest_time_limit, 100000)


-- >>>>>>>> shade2/quest.hsp:313 *quest_exit ..
local function on_quest_exit(quest)
   local quest_data = data["elona_sys.quest"]:ensure(quest._id)
   if quest_data.on_quest_exit then
      quest_data.on_quest_exit(quest)
   end

   local result = Event.trigger("elona_sys.on_quest_map_leave", {quest = quest})
   if result then
      return
   end

   if quest.state ~= "completed" then
      Quest.fail(quest)
      Input.query_more()
   end

   local s = save.elona_sys
   s.immediate_quest_uid = nil
   s.quest_time_limit = 0
   s.quest_time_limit_notice_interval = 0
end
-- <<<<<<<< shade2/quest.hsp:329 	return ..

-- >>>>>>>> shade2/map.hsp:176 	if mType=mTypeQuest{ ..
local function quest_exit_on_leave(map, params)
   local s = save.elona_sys

   if map:has_type("quest") and s.immediate_quest_uid then
      local quest = assert(Quest.get(s.immediate_quest_uid))
      on_quest_exit(quest)
   end
end
-- <<<<<<<< shade2/map.hsp:182 		} ..

Event.register("base.on_map_leave", "Check quest status", quest_exit_on_leave, 100000)

-- >>>>>>>> shade2/quest.hsp:331 *quest_death ..
local function quest_on_death(_, params)
   if not Quest.is_in_immediate_quest_map() then
      return
   end

   local player = params.player
   local map = player:current_map()
   assert(player:revive())

   Skill.gain_skill_exp(player, "elona.stat_charisma", -500)
   Skill.gain_skill_exp(player, "elona.stat_will", -500)

   local prev_map_uid, prev_x, prev_y = map:previous_map_and_location()
   local ok, prev_map = assert(Map.load(prev_map_uid))

   -- quest_exit_on_leave above also gets called from base.on_map_leave, which
   -- will fail the current quest.
   assert(Map.travel_to(prev_map, { start_x = prev_x, start_y = prev_y }))

   return "turn_begin"
end
-- <<<<<<<< shade2/quest.hsp:337 	goto *map_exit ..

Event.register("base.on_player_death", "Revive if inside quest", quest_on_death, 100000)

local function quest_create_rewards(_, params)
   local quest = params.quest
   Quest.create_rewards(quest)

   local player = Chara.player()
   Effect.modify_karma(player, 1)

   local fame_gained = Calc.calc_fame_gained(player, quest.difficulty * 3 + 10)
   Gui.mes_c("quest.completed_taken_from", "Green", quest.client_name)
   Gui.mes_c("quest.gain_fame", "Green", fame_gained)
   player.fame = player.fame + fame_gained
   Gui.mes("common.something_is_put_on_the_ground")
   Gui.play_sound("base.complete1")
end
Event.register("elona_sys.on_quest_completed", "Create default quest rewards", quest_create_rewards, 200000)

local function quest_failed_callback(_, params)
   local quest = params.quest
   local quest_data = data["elona_sys.quest"]:ensure(quest._id)
   if quest_data.on_failure then
      quest_data.on_failure(quest)
   end
end
Event.register("elona_sys.on_quest_failed", "Run on_quest_failed callback", quest_failed_callback, 200000)

local function check_escort_quest_targets(map)
   local quest = Quest.get_immediate_quest()
   if quest and quest._id == "elona.escort" then
      ElonaQuest.update_target_count_escort(quest, map)
   end
end
Event.register("elona_sys.on_quest_check", "Check escort quest targets", check_escort_quest_targets)

local function calc_power_after_resistance(chara, effect, element, power)
-- >>>>>>>> shade2/chara_func.hsp:1008 *conCalc ...
   local level = chara:resist_grade(element._id)
   power = (Rand.rnd(math.floor(power / 2) + 1) + math.floor(power / 2)) * 100 / (50 + level * 50)

   if level >= Const.RESIST_LEVEL_MINIMUM and power < 40 then
      return 0
   end

   return power
   -- <<<<<<<< shade2/chara_func.hsp:1016 	return ..
end

local function calc_effect_power_resist(chara, params, power)
   local effect = params.effect

   if effect.related_element ~= nil then
      local element = data["base.element"]:ensure(effect.related_element)
      power = calc_power_after_resistance(chara, effect, element, power)
   end

   return power
end
Event.register("elona_sys.calc_effect_power",
               "Effect power from elemental resistance",
               calc_effect_power_resist, { priority = 50000 })

local function calc_effect_power_reduction(chara, params, power)
   local cb = params.effect.calc_adjusted_power
   if cb then
      power = math.floor(cb(chara, power))
   end
   return power
end
Event.register("elona_sys.calc_effect_power",
               "Effect power from power reduction",
               calc_effect_power_reduction, { priority = 60000 })

Event.register("elona_sys.on_apply_effect", "Stop activity", function(chara, params)
                  if params.effect.stops_activity then
                     chara:remove_activity()
                  end
end)

local function proc_confusion_message(chara)
   if chara:is_player() and chara:has_effect("elona.confusion") then
      Gui.mes_duplicate()
      Gui.mes("action.move.confused")
   end
end
Event.register("base.before_chara_moved", "Proc confusion message", proc_confusion_message, { priority = 200000 })

local function on_cast_magic(_, params, result)
   local did_something, turn_result = params.magic:cast(params.magic_params)
   result.did_something = did_something
   result.turn_result = turn_result
end
Event.register("elona_sys.on_cast_magic", "Cast magic", on_cast_magic, { priority = 100000 })

require("mod.elona_sys.event.instantiate_feat")
require("mod.elona_sys.event.instantiate_item")
require("mod.elona_sys.event.instantiate_mef")
