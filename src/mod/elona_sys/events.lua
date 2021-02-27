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
local elona_Quest = require("mod.elona.api.Quest")
local Enum = require("api.Enum")

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
      chara:add_effect_turns(effect_id, -1)
   end

   return result
end
Event.register("base.on_chara_turn_end", "Proc effect on_turn_end", proc_effects_turn_end, { priority = 110000 })

local function proc_player_turn_end(chara, params)
   -- >>>>>>>> shade2/main.hsp:883 		if cBurden(pc)>=burdenHeavy{ ...
   if not chara:is_player() then
      return
   end

   if chara:calc("inventory_weight_type") >= Enum.Burden.Heavy and not config.base.debug_no_weight then
      if Rand.one_in(20) then
         Gui.mes("action.backpack_squashing", chara)
         local damage = chara:calc("max_hp") * (chara:calc("inventory_weight") * 10 / chara:calc("max_inventory_weight") + 10) / 200 + 1
         chara:damage_hp(damage, "elona.burden")
      end
   end

   -- TODO hunger nutrition

   Skill.refresh_speed(chara)
   -- <<<<<<<< shade2/main.hsp:887 		refreshSpeed cc ..
end
Event.register("base.on_chara_turn_end", "Proc player burden/hunger/speed", proc_player_turn_end, { priority = 120000 })

local function update_awake_hours()
   -- >>>>>>>> shade2/main.hsp:627 	if mType=mTypeWorld{ ...
   local s = save.elona_sys
   local map = Map.current()
   if Map.is_world_map(map) then
      if Rand.one_in(3) then
         s.awake_hours = s.awake_hours + 1
      end
      if Rand.one_in(15) then
         Gui.mes("action.move.global.nap")
         s.awake_hours = math.max(0, s.awake_hours - 3)
      end
   end
   if not map:calc("prevents_adding_awake_hours") then
      s.awake_hours = s.awake_hours + 1
   end
   -- <<<<<<<< shade2/main.hsp:632 		} ...
end

Event.register("base.on_hour_passed", "Update awake hours", update_awake_hours)

local function init_save()
   local s = save.elona_sys
   s.awake_hours = 0
   s.npc_memory = { killed = {}, generated = {} }
   s.item_memory = { known = {}, generated = {} }
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
   s.reservable_spellbook_ids = table.set {}
end

Event.register("base.on_init_save", "Init save (elona_sys)", init_save)

local function show_element_text_damage(target, source, tense, element)
   Gui.mes("element.damage." .. element._id, target)
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
                                is_third_person)
   local map = target:current_map()
   if not map:is_in_fov(target.x, target.y) then
      return
   end

   -- >>>>>>>> shade2/action.hsp:1277 		if sync(tc){ ...
   if extra_attacks > 0 then
      Gui.mes("damage.furthermore")
      Gui.mes_continue_sentence()
   end

   local skill = "elona.martial_arts" -- TODO

   if weapon then
      skill = weapon:calc("skill")
   end
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
                                   params.is_third_person)

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
                                   params.is_third_person)

                  if params.element and params.element._id == "elona.nether" and params.attacker and params.damage > 0 then
                     params.attacker:heal_hp(Rand.rnd(params.damage * (200 + params.element_power) / 1000 + 5))
                  end

                  -- This is so the chip will become hidden when the below
                  -- animation is played.
                  Gui.update_screen()

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
                  Gui.update_screen()
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

Event.register("base.on_map_enter", "Refresh sidequests (when map entered)",
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


-- The following events are necessary to run on every object each time
-- a map is loaded because event callbacks are not serialized.

Event.register("base.on_item_instantiated", "Connect item events",
               function(item)
                  -- This is where the callbacks on item prototypes
                  -- like "on_use" and "on_drink" get used. It might
                  -- be a bit difficult to find with the function name
                  -- generation.
                  --
                  -- The reason there are boolean flags indicating if
                  -- an action can be taken ("can_eat", "can_open") is
                  -- because it makes it easier to temporarily disable
                  -- the action. Without this the check relies on
                  -- whether or not the event handler is present, and
                  -- it is difficult to preserve the state of event
                  -- handlers across serialization.
                  local actions = {
                     "use",        -- on_use,        can_use,        elona_sys.on_item_use
                     "eat",        -- on_eat,        can_eat,        elona_sys.on_item_eat
                     "drink",      -- on_drink,      can_drink,      elona_sys.on_item_drink
                     "read",       -- on_read,       can_read,       elona_sys.on_item_read
                     "zap",        -- on_zap,        can_zap,        elona_sys.on_item_zap
                     "open",       -- on_open,       can_open,       elona_sys.on_item_open
                     "dip_source", -- on_dip_source, can_dip_source, elona_sys.on_item_dip_source
                     "throw",      -- on_throw,      can_throw,      elona_sys.on_item_throw
                     "descend",    -- on_descend,    can_descend,    elona_sys.on_item_descend
                     "ascend",     -- on_ascend,     can_ascend,     elona_sys.on_item_ascend
                  }

                  for _, action in ipairs(actions) do
                     local event_id = "elona_sys.on_item_" .. action
                     local event_name = "Item prototype on_" .. action .. " handler"

                     -- If a handler is left over from previous instantiation
                     if item:has_event_handler(event_id) then
                        item:disconnect_self(event_id, event_name)
                     end

                     if item.proto["on_" .. action] then
                        item:connect_self(event_id, event_name, item.proto["on_" .. action])
                     end

                     if item:has_event_handler("elona_sys.on_item_" .. action) then
                        item["can_" .. action] = true
                     else
                        item["can_" .. action] = nil
                     end
                  end
end)

Event.register("base.on_item_instantiated", "Permit item actions",
               function(item)
                  if item:has_category("elona.container") then
                     item.can_open = true
                  end

                  if item:has_category("elona.food")
                     or item:has_category("elona.cargo_food")
                  then
                     item.can_eat = true
                  end

                  if item:has_category("elona.drink") then
                     item.can_throw = true
                  end
end)

local IItem = require("api.item.IItem")
Event.register("base.on_hotload_object", "reload events for item", function(obj)
                  if class.is_an(IItem, obj) then
                     obj:instantiate()
                  end
end)

-- Create event handlers to call the function callbacks with these names when
-- the corresponding event is triggered.
local feat_events = {
   on_bash = "elona_sys.on_bash",
   on_activate = "elona_sys.on_feat_activate",
   on_search = "elona_sys.on_feat_search",
   on_open = "elona_sys.on_feat_open",
   on_close = "elona_sys.on_feat_close",
   on_descend = "elona_sys.on_feat_descend",
   on_ascend = "elona_sys.on_feat_ascend",
   on_bumped_into = "elona_sys.on_feat_bumped_into",
   on_stepped_on = "elona_sys.on_feat_stepped_on",
}

for cb_name, event_id in pairs(feat_events) do
   local name = ("Feat prototype %s handler"):format(cb_name)
   local handler = function(feat, params, result)
      if feat.proto[cb_name] then
         result = feat.proto[cb_name](feat, params, result) or result
      end
      return result
   end
   Event.register(event_id, name, handler, { priority = 100000 })
end

local IFeat = require("api.feat.IFeat")
Event.register("base.on_hotload_object", "reload events for feat", function(obj)
                  if class.is_an(IFeat, obj) then
                     obj:instantiate()
                  end
end)

local function feat_bumped_into_handler(chara, p, result)
   for _, feat in Feat.at(p.x, p.y, chara:current_map()) do
      if feat:calc("is_solid") then
         feat:emit("elona_sys.on_feat_bumped_into", {chara=chara})
         result.blocked = true
      end
   end

   return result
end
Event.register("base.before_chara_moved", "Feat bumped into behavior", feat_bumped_into_handler)

local function proc_confusion_message(chara)
   if chara:is_player() and chara:has_effect("elona.confusion") then
      Gui.mes_duplicate()
      Gui.mes("action.move.confused")
   end
end
Event.register("base.before_chara_moved", "Proc confusion message", proc_confusion_message, { priority = 200000 })

local function feat_stepped_on_handler(chara, p, result)
   for _, feat in Feat.at(p.x, p.y, chara:current_map()) do
      feat:emit("elona_sys.on_feat_stepped_on", {chara=chara})
   end

   return result
end
Event.register("base.on_chara_moved", "Feat stepped on behavior", feat_stepped_on_handler)

Event.register("base.on_mef_instantiated", "Connect mef events",
               function(mef)
                  if mef.proto.on_stepped_on then
                     mef:connect_self("elona_sys.on_mef_stepped_on",
                                      "Mef prototype on_stepped_on handler",
                                      mef.proto.on_stepped_on)
                  end
                  if mef.proto.on_stepped_off then
                     mef:connect_self("elona_sys.on_mef_stepped_off",
                                      "Mef prototype on_stepped_off handler",
                                      mef.proto.on_stepped_off)
                  end
                  if mef.proto.on_updated then
                     mef:connect_self("base.on_mef_updated",
                                      "Mef prototype on_update handler",
                                      mef.proto.on_updated)
                  end
                  if mef.proto.on_removed then
                     mef:connect_self("base.on_object_removed",
                                      "Mef prototype on_removed handler",
                                      mef.proto.on_removed)
                  end
               end,
               {priority = 10000})

local function mef_stepped_on_handler(chara, p, result)
   -- >>>>>>>> shade2/main.hsp:747 	if map(cX(tc),cY(tc),8)!0{ ..
   local mef = Mef.at(chara.x, chara.y, chara:current_map())
   if mef then
      mef:emit("elona_sys.on_mef_stepped_on", {chara=chara})
   end

   return result
   -- <<<<<<<< shade2/main.hsp:770 		} ..
end
Event.register("base.on_chara_pass_turn", "Mef stepped on behavior", mef_stepped_on_handler)

local function mef_stepped_off_handler(chara, p, result)
   local mef = Mef.at(chara.x, chara.y, chara:current_map())
   if mef then
      local inner_result = mef:emit("elona_sys.on_mef_stepped_off", {chara=chara})
      if inner_result and inner_result.blocked then
         return inner_result
      end
   end

   return result
end
Event.register("base.before_chara_moved", "Mef stepped off behavior", mef_stepped_off_handler)

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
   if data["base.music"][music_id] then
      Gui.play_music(music_id)
   end
end

Event.register("base.on_map_enter", "Play map music", play_map_music)

local PlayerLightDrawable = require("api.gui.PlayerLightDrawable")
local function add_player_light(player, params)
   if params.previous_player then
      local remove = {}
      for i, d in ipairs(params.previous_player.drawables) do
         if class.is_an(PlayerLightDrawable, d.drawable) then
            remove[#remove+1] = i
         end
      end
      table.remove_indices(params.previous_player.drawables, remove)
   end

   for _, d in ipairs(player.drawables) do
      if class.is_an(PlayerLightDrawable, d.drawable) then
         return
      end
   end

   table.insert(player.drawables, { drawable = PlayerLightDrawable:new() })
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
   if quest_data.on_failed then
      quest_data.on_failed(quest)
   end
end
Event.register("elona_sys.on_quest_failed", "Run on_quest_failed callback", quest_failed_callback, 200000)

local function check_escort_quest_targets(map)
   local quest = Quest.get_immediate_quest()
   if quest and quest._id == "elona.escort" then
      elona_Quest.update_target_count_escort(quest, map)
   end
end
Event.register("elona_sys.on_quest_check", "Check escort quest targets", check_escort_quest_targets)
