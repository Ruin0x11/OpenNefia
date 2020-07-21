local Chara = require("api.Chara")
local Event = require("api.Event")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local NpcMemory = require("mod.elona_sys.api.NpcMemory")
local Skill = require("mod.elona_sys.api.Skill")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Rand = require("api.Rand")
local World = require("api.World")
local Resolver = require("api.Resolver")
local ElonaAction = require("mod.elona.api.ElonaAction")
local MapObject = require("api.MapObject")
local Role = require("mod.elona_sys.api.Role")
local Text = require("mod.elona.api.Text")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")

--
--
-- damage_hp events
--
--

local function retreat_in_fear(chara, params)
   if chara.hp < chara:calc("max_hp") / 5 then
      if chara:is_player() or chara:has_effect("elona.fear") then
         return
      end

      if chara:is_immune_to_effect("elona.fear") then
         return
      end

      local retreats = params.damage * 100 / chara:calc("max_hp") + 10 > Rand.rnd(200)

      if params.attacker and params.attacker:has_trait("elona.no_fear") then
         retreats = false
      end

      if retreats then
         assert(chara:set_effect_turns("elona.fear", Rand.rnd(20) + 5))
         Gui.mes_c_visible("damage.runs_away_in_terror", chara.x, chara.y, "Blue", chara)
      end
   end
end

Event.register("base.on_damage_chara",
               "Retreat in fear", retreat_in_fear)

local function disturb_sleep(chara, params)
   if not params.element or not params.element.preserves_sleep then
      if chara:has_effect("elona.sleep") then
         chara:remove_effect("elona.sleep")
         Gui.mes("sleep is disturbed " .. chara.uid)
      end
   end
end

Event.register("base.on_damage_chara",
               "Disturb sleep", disturb_sleep)

local function explodes(chara)
   if chara:calc("is_explodable") then
      local chance = chara:calc("explode_chance") or Rand.one_in_percent(3)
      if Rand.percent_chance(chance) then
         chara.is_about_to_explode = true
         Gui.mes_c("damage.explode_click", "LightBlue")
      end
   end
end

Event.register("base.on_damage_chara",
               "Explodes behavior", explodes)

local function splits(chara, params)
   if chara:calc("splits") then
      local threshold = chara:calc("split_threshold") or 20
      local chance = chara:calc("split_chance") or Rand.one_in_percent(10)
      if params.damage > chara:calc("max_hp") / threshold or Rand.percent_chance(chance) then
         if not Map.is_world_map() then
            if chara:clone() then
               Gui.mes(chara.uid .. " splits.")
            end
         end
      end
   end
end

-- TODO: only triggers depending on damage events flag
Event.register("base.on_damage_chara",
               "Split behavior", splits)

local split2_effects = {
   "elona.confusion",
   "elona.dimming",
   "elona.poison",
   "elona.paralysis",
   "elona.blindness",
}

local function splits2(chara, params)
   if chara:calc("splits2") then
      local chance = chara:calc("split2_chance") or Rand.one_in_percent(3)
      if Rand.percent_chance(chance) then
         if not fun.iter(split2_effects)
            :any(function(e) return chara:has_effect(e) end)
         then
            if not Map.is_world_map() then
               if chara:clone() then
                  Gui.mes(chara.uid .. " splits.")
               end
            end
         end
      end
   end
end

Event.register("base.on_damage_chara",
               "Split behavior (2)", splits2)

local function is_quick_tempered(chara, params)
   if chara:calc("is_quick_tempered") then
      if not chara:has_effect("elona.fury") then
         if Rand.one_in(20) then
            Gui.mes_visible(chara.uid .. " engulfed in fury", chara.x, chara.y, "Blue")
            chara:set_effect_turns("elona.fury", Rand.rnd(30) + 15)
         end
      end
   end
end

Event.register("base.on_damage_chara",
               "Quick tempered", is_quick_tempered)

local function play_heartbeat(chara)
   if chara:is_player() then
      local threshold = 25 * 0.01
      if chara.hp < chara:calc("max_hp") * threshold then
         Gui.play_sound("base.heart1")
      end
   end
end

Event.register("base.on_damage_chara",
               "Play heartbeat sound", play_heartbeat)

local function proc_lay_hand(chara)
   if chara.hp < 0 then
      for _, ally in chara:iter_party() do
         if Chara.is_alive(ally)
            and chara.uid ~= ally.uid
            and ally:calc("has_lay_hand")
            and ally:calc("is_lay_hand_available")
         then
            ally:reset("is_lay_hand_available", false)
            Gui.mes("Lay hand!")
            Gui.mes(chara.uid .. " is healed.")
            chara:reset("hp", chara.max_hp / 2)
            Gui.play_sound("base.pray2")
            break
         end
      end
   end
end

Event.register("base.after_chara_damaged",
               "Proc lay hand", proc_lay_hand)

local function proc_sandbag(chara)
   if chara.hp < 0 and chara:calc("is_hung_on_sandbag") then
      chara.hp = chara:calc("max_hp")
   end
end

Event.register("base.after_chara_damaged",
               "Proc sandbag", proc_sandbag)

local function calc_initial_resistance_level(chara, element)
   if chara:is_player() then
      return 100
   end

   local initial_level = chara:resist_level(element._id)
   local level = math.min(chara:calc("level") * 4 + 96, 300)
   if initial_level ~= 0 then
      if initial_level < 100 or initial_level > 500 then
         level = initial_level
      else
         level = level + initial_level
      end
   end
   if element.calc_initial_resist_level then
      level = element.calc_initial_resist_level(chara, level)
   end
   return level
end

local initial_skills = {
   ["elona.axe"] = 4,
   ["elona.blunt"] = 4,
   ["elona.bow"] = 4,
   ["elona.crossbow"] = 4,
   ["elona.evasion"] = 4,
   ["elona.faith"] = 4,
   ["elona.healing"] = 4,
   ["elona.heavy_armor"] = 4,
   ["elona.light_armor"] = 4,
   ["elona.long_sword"] = 4,
   ["elona.martial_arts"] = 4,
   ["elona.meditation"] = 4,
   ["elona.medium_armor"] = 4,
   ["elona.polearm"] = 4,
   ["elona.scythe"] = 4,
   ["elona.shield"] = 3,
   ["elona.short_sword"] = 4,
   ["elona.stat_luck"] = 50,
   ["elona.stave"] = 4,
   ["elona.stealth"] = 4,
   ["elona.throwing"] = 4
}

local function init_skills_from_table(chara, tbl)
   for skill_id, level in pairs(tbl) do
      local init = Skill.calc_initial_skill_level(skill_id, level, chara:base_skill_level(skill_id), chara:calc("level"), chara)
      chara:set_base_skill(skill_id, init.level, init.potential, 0)
   end
end

local function init_skills(chara)
   local elements = data["base.element"]:iter():filter(function(e) return e.can_resist end)
   for _, element in elements:unwrap() do
      local level = calc_initial_resistance_level(chara, element)
      chara:set_base_resist(element._id, level, 0, 0)
   end

   init_skills_from_table(chara, initial_skills)
end

Event.register("base.on_build_chara",
               "Init skills", init_skills)

local function apply_race_class(chara)
   -- TODO merge with charamake
   local race_data = Resolver.run("elona.race", {}, { chara = chara })
   local class_data = Resolver.run("elona.class", {}, { chara = chara })

   chara:mod_base_with(race_data, "merge")
   chara:mod_base_with(class_data, "merge")

   local rest = Resolver.resolve(chara, {object = chara, diff_only = true, override_method = true})
   chara:mod_base_with(rest, "set")
end

Event.register("base.on_normal_build",
               "Init race and class", apply_race_class)

local function init_lay_hand(chara)
   if chara.has_lay_hand then
      chara.is_lay_hand_available = true
   end
end

Event.register("base.on_build_chara",
               "Init lay hand", init_lay_hand)

local function init_chara_defaults(chara)
   chara.performance_interest = chara.performance_interest or 0
   chara.performance_interest_revive_date = chara.performance_interest_revive_date or 0

   if chara:is_player() then
      chara.nutrition = 9000
   else
      chara.nutrition = 5000 + Rand.rnd(4000)
   end

   chara.height = chara.height + Rand.rnd(chara.height / 5 + 1) - Rand.rnd(chara.height / 5 + 1)

   chara.required_experience = Skill.calc_required_experience(chara)

   if chara:is_player() then
      chara.initial_max_cargo_weight = 80000
      chara.max_cargo_weight = chara.initial_max_cargo_weight
   end
end

Event.register("base.on_build_chara",
               "Init chara_defaults", init_chara_defaults)

local function init_chara_image(chara)
   if chara.male_image and chara.gender == "male" then
      chara.image = chara.male_image
   end
   if chara.female_image and chara.gender == "female" then
      chara.image = chara.female_image
   end
end

Event.register("base.on_build_chara",
               "Init chara image", init_chara_image)



local function calc_damage_fury(chara, params, result)
   if chara:has_effect("elona.fury") then
      result = result * 2
   end
   if params.attacker and params.attacker:has_effect("elona.fury") then
      result = result * 2
   end
   return result
end

Event.register("base.hook_calc_damage",
               "Proc fury", calc_damage_fury)


local function calc_damage_resistance(chara, params, result)
   local element = params.element
   if element and element.can_resist then
      local resistance = math.floor(chara:resist_level(element._id) / 50)
      if resistance < 3 then
         result = result * 150 / math.clamp(resistance * 50 + 50, 40, 150)
      elseif resistance < 10 then
         result = result * 100 / (resistance * 50 + 50)
      else
         result = 0
      end
      result = result * 100 / (chara:resist_level("elona.magic") / 2 + 50)
   end
   return result
end

Event.register("base.hook_calc_damage",
               "Proc elemental resistance", calc_damage_resistance)

local function calc_element_damage(chara, params, result)
   local element = params.element
   if element and element.on_modify_damage then
      result = element.on_modify_damage(chara, result)
   end
   return result
end

Event.register("base.hook_calc_damage",
               "Proc elemental damage", calc_element_damage)

local function is_immune_to_elemental_damage(chara, params, result)
   if chara:calc("is_immune_to_elemental_damage") then
      if params.element and params.element._id ~= "elona.magic" then
         result = 0
      end
   end
   return result
end

Event.register("base.hook_calc_damage",
               "Proc elemental damage immunity", is_immune_to_elemental_damage)

local function is_metal_damage(chara, params, result)
   if chara:calc("is_metal") then
      result = Rand.rnd(result / 10 + 2)
   end
   return result
end

Event.register("base.hook_calc_damage",
               "Proc is_metal damage", is_metal_damage)

local function nullify_damage(chara, params, result)
   local chance = chara:calc("nullify_damage") or 0
   if chance > 0 and Rand.percent_chance(chance) then
      result = 0
   end
   return result
end

Event.register("base.hook_calc_damage",
               "Proc nullify damage", nullify_damage)

local function calc_kill_exp(victim, params)
   local level = victim:calc("level")
   local result = math.clamp(level, 1, 200) * math.clamp(level + 1, 1, 200) * math.clamp(level + 2, 1, 200) / 20 + 8
   if level > params.attacker:calc("level") then
      result = result / 4
   end
   if victim:calc("splits") or victim:calc("splits2") then
      result = result / 20
   end
   return result
end

Event.register("base.on_calc_kill_exp",
               "Kill experience formula", calc_kill_exp)

Event.register(
   "base.hook_generate_chara",
   "Shade generation",
   function(_, params, result)
      if params.id ~= "elona.shade" then
         return result
      end

      if not Rand.one_in(5) then
         return result
      end

      params.level = params.level * 2
      if params.quality > 3 then
         params.quality = 3
      end
      local Charagen = require("mod.tools.api.Charagen")
      params.id = Charagen.random_chara_id_raw(params.level, params.filter, params.category)

      -- using Chara.create would cause recursion
      local chara = MapObject.generate_from("base.chara", params.id, params.gen_params)

      chara.is_shade = true
      chara.title = "shade"
      chara.image = "elona.chara_shade"

      return chara
end)

Event.register("base.generate_chara_name", "Elona character name generation", function(_, _, result)
                  if result and result ~= "" then
                     return result
                  end
                  return Text.random_name()
end)

Event.register("base.generate_title", "Elona title generation", function(_, params, result)
                  if result and result ~= "" then
                     return result
                  end
                  return Text.random_title(params.kind, params.seed or nil)
end)

Event.register("base.on_chara_generated", "npc memory", function(chara) NpcMemory.on_generated(chara._id) end)
Event.register("base.on_object_cloned", "npc memory",
               function(_, params)
                  if params.object._type == "base.chara" then
                     NpcMemory.on_generated(params.object._id)
                  end
               end)
Event.register("base.on_kill_chara", "npc memory",
               function(victim, params)
                  NpcMemory.on_killed(victim._id)
               end)
Event.register("base.on_map_leave", "npc memory",
               function(map)
                  if map.is_temporary then
                     for _, v in map:iter_charas() do
                        if Chara.is_alive(v) then
                           print( "forget " .. v._id)
                           NpcMemory.forget_generated(v._id)
                        end
                     end
                  end
               end)


---
--- Dialog
---

local function bump_into_chara(player, params, result)
   local on_cell = params.chara
   local reaction = on_cell:reaction_towards(player)

   if reaction > 0 then
      if on_cell:is_ally() or on_cell.faction == "base.citizen" or Gui.player_is_running() then
         if player:swap_places(on_cell) then
            Gui.mes("action.move.displace.text", on_cell)
            Gui.set_scroll()
            on_cell:emit("elona.on_displaced")
         end
         return "turn_end"
      end

      Dialog.talk_to_chara(on_cell)
      return "player_turn_query"
   end

   -- TODO: relation as -1
   if reaction <= 0 then
      player:set_target(on_cell)
      ElonaAction.melee_attack(player, on_cell)
      Gui.set_scroll()
      return "turn_end"
   end

   return result
end

Event.register("elona_sys.on_player_bumped_into_chara",
               "Attack/swap position", bump_into_chara)


local function calc_dialog_choices(speaker, params, result)
   print("calc1")
   table.insert(result, {"talk", "talk.npc.common.choices.talk"})

   if speaker.roles then
      for id, _ in pairs(speaker.roles) do
         local role_data = data["elona.role"]:ensure(id)
         if role_data.dialog_choices then
            for _, choice in ipairs(role_data.dialog_choices) do
               if type(choice) == "function" then
                  local choices = choice(speaker, params)
                  assert(type(choices) == "table")
                  for _, choice in ipairs(choices) do
                     table.insert(result, choice)
                  end
               else
                  table.insert(result, choice)
               end
            end
         end
      end
   end

   return result
end

Event.register("elona.calc_dialog_choices", "Default NPC dialog choices", calc_dialog_choices)


local function refresh_hp_mp_stamina(chara, params, result)
   local mp_factor = chara:skill_level("elona.stat_magic") * 2
      + chara:skill_level("elona.stat_will")
      + (chara:skill_level("elona.stat_learning") / 3)
      * (chara:calc("level") / 25)
      + chara:skill_level("elona.stat_magic")

   chara.max_mp = math.floor(math.clamp(mp_factor, 1, 1000000) * (chara:skill_level("elona.stat_mana") / 100))

   local hp_factor = chara:skill_level("elona.stat_constitution") * 2
      + chara:skill_level("elona.stat_strength")
      + (chara:skill_level("elona.stat_will") / 3)
      * (chara:calc("level") / 25)
      + chara:skill_level("elona.stat_strength")

   chara.max_hp = math.floor(math.clamp(hp_factor, 1, 1000000) * (chara:skill_level("elona.stat_life") / 100)) + 5

   chara.max_stamina = math.floor(100 + (chara:skill_level("elona.stat_constitution") + chara:skill_level("elona.stat_strength")) / 5
                                     + chara:trait_level("elona.stamina") * 8)
end

Event.register("base.on_refresh", "Update max HP/MP/stamina", refresh_hp_mp_stamina)

local function refresh_invisibility(chara, params, result)
   Effect.refresh_visibility(chara)
end

Event.register("base.on_refresh", "Update invisibility", refresh_invisibility)

local function refresh_other_chara(chara, params)
   if not chara:is_allied() then
      chara.hp = chara:calc("max_hp")
      chara.hp = chara:calc("max_mp")
      chara:remove_effect("elona.insanity")

      local map = chara:current_map()
      assert(map)

      if map:calc("has_anchored_npcs") then
         chara.initial_x = chara.x
         chara.initial_y = chara.y
      end

      if not chara.is_quest_target then
         chara:reset_ai()
      end

      if Role.has(chara, "elona.guard") then
         if Chara.player():calc("karma") < -30 then
            if Chara.player():calc("level") > chara:calc("level") then
               Skill.gain_level(chara)
            end
            if not Chara.player():has_effect("elona.incognito") then
               chara.ai_state.hate = 200
               chara:mod_reaction_at(Chara.player(), -1000)
            end
         end
      end

      if map:has_type({"town", "guild"}) then
         chara:remove_effect("elona.sleep")
         local date = World.date()
         if date.hour >= 22 or date.hour < 7 then
            if Rand.one_in(6) then
               chara:set_effect_turns("elona.sleep", Rand.rnd(400))
            end
         end
      end
   end
end

Event.register("base.on_chara_refresh_in_map", "Refresh other character", refresh_other_chara)

local footstep = 0
local footsteps = {"base.foot1a", "base.foot1b"}
local snow_footsteps = {"base.foot2a", "base.foot2b", "base.foot2c"}
Event.register("elona_sys.hook_player_move", "Leave footsteps",
               function(_, params, result)
                  local player = params.chara
                  local map = player:current_map()
                  if (player.x ~= result.pos.x or player.y ~= result.pos.y)
                     and Map.can_access(result.pos.x, result.pos.y, map)
                  then
                     local tile = map:tile(params.chara.x, params.chara.y)
                     if tile.kind == Enum.TileRole.Snow then
                        Gui.play_sound(snow_footsteps[footstep%2+1])
                        footstep = footstep + Rand.rnd(2)
                     else
                        if map:has_type("world_map") then
                           Gui.play_sound(footsteps[footstep%2+1])
                           footstep = footstep + 1
                        end
                     end
                  end

                  return result
               end)

local function respawn_mobs()
   if save.base.play_turns % 20 == 0 then
      local Calc = require("mod.elona.api.Calc")
      --Calc.respawn_mobs()
   end
end

Event.register("base.on_minute_passed", "Respawn mobs", respawn_mobs)

local function on_regenerate(chara)
   if Rand.one_in(6) then
      local amount = Rand.rnd(chara:skill_level("elona.healing") / 3 + 1) + 1
      chara:heal_hp(amount, true)
   end
   if Rand.one_in(5) then
      local amount = Rand.rnd(chara:skill_level("elona.meditation") / 2 + 1) + 1
      chara:heal_mp(amount, true)
   end
end

Event.register("base.on_regenerate", "Regenerate HP/MP", on_regenerate)

local function gain_healing_meditation_exp(chara)
   local exp = 0
   if chara:calc("hp") ~= chara:calc("max_hp") then
      local healing = chara:skill_level("elona.healing")
      if healing < chara:skill_level("elona.stat_constitution") then
         exp = 5 + healing / 5
      end
   end
   Skill.gain_skill_exp(chara, "elona.healing", exp, 1000)

   exp = 0
   if chara:calc("mp") ~= chara:calc("max_mp") then
      local meditation = chara:skill_level("elona.meditation")
      if meditation < chara:skill_level("elona.stat_magic") then
         exp = 5 + meditation / 5
      end
   end
   Skill.gain_skill_exp(chara, "elona.meditation", exp, 1000)
end

local function gain_stealth_experience(chara)
   local exp = 2

   local map = chara:current_map()
   if map and map:has_type("world_map") and Rand.one_in(20) then
      exp = 0
   end

   Skill.gain_skill_exp(chara, "elona.stealth", exp, 0, 1000)
end

local function gain_weight_lifting_experience(chara)
   local exp = 0

   if chara:calc("inventory_weight_type") > 0 then
      exp = 4

      local map = chara:current_map()
      if map and map:has_type("world_map") and Rand.one_in(20) then
         exp = 0
      end
   end

   Skill.gain_skill_exp(chara, "elona.weight_lifting", exp, 0, 1000)
end

local function update_emotion_icon(chara)
   chara.emotion_icon_turns = math.max(chara.emotion_icon_turns - 1, 0)
   if chara.emotion_icon and chara.emotion_icon_turns == 0 then
      chara.emotion_icon = nil
   end
end

Event.register("base.before_chara_turn_start", "Update emotion icon", update_emotion_icon)

local function proc_enough_exp_for_level(chara)
   while chara.experience >= chara.required_experience do
      if chara:is_player() then
         Gui.play_sound("base.ding1")
         Gui.mes_alert()
      end
      Skill.gain_level(chara, true)
   end
end

Event.register("base.before_chara_turn_start", "Check if character leveled up", proc_enough_exp_for_level, {priority = 90000})

local function gain_experience_at_turn_start(chara)
   if not chara:is_player() then
      return
   end

   local turn = chara.turns_alive % 10
   if turn == 1 then
      Chara.iter_party()
         :filter(Chara.is_alive)
         :each(gain_healing_meditation_exp)
   elseif turn == 2 then
      gain_stealth_experience(chara)
   elseif turn == 3 then
      gain_weight_lifting_experience(chara)
   elseif turn == 4 then
      if not chara:has_activity() then
         chara:heal_stamina(2)
      end
   end
end

Event.register("base.before_chara_turn_start", "Gain experience", gain_experience_at_turn_start)

local function proc_return(chara)
   if not chara:is_player() then
      return
   end

   local s = save.elona
   if s.turns_until_cast_return > 0 then
      s.turns_until_cast_return = s.turns_until_cast_return - 1

      local map = chara:current_map()
      if not map then
         s.turns_until_cast_return = 0
      end
      if map:calc("prevents_return") then
         Gui.mes("magic.return.prevented.normal")
         s.turns_until_cast_return = 0
         return
      end

      if s.turns_until_cast_return <= 0 and not DeferredEvent.is_pending() then
         local has_escort = Chara.iter_allies()
            :filter(Chara.is_alive)
            :extract("is_quest_escort")
            :any()

         if has_escort then
            Gui.mes("magic.return.prevented.normal")
            return
         end

         if chara:calc("inventory_weight_type") >= 4 then
            Gui.mes("magic.return.prevented.overweight")
            return
         end

         local dest = s.return_destination_map_uid
         if dest == nil or dest == map.uid then
            Gui.mes("common.nothing_happens")
            return
         end

         local blocked = Event.trigger("elona.before_cast_return", {}, false)
         if blocked then
            return
         end

         Gui.play_sound("base.teleport1")
         Gui.mes("magic.return.door_opens")
         -- TODO
         Gui.mes_halt()
         Gui.update_screen()
         local map_uid = s.return_destination_map_uid
         s.return_destination_map_uid = nil

         Map.travel_to(map_uid)
      end
   end
end

Event.register("base.before_chara_turn_start", "Proc return event", proc_return)

local function init_save()
   local s = save.elona
   s.turns_until_cast_return = 0
   s.return_destination_map_uid = nil
   s.holy_well_count = 0
   s.guild = nil
   s.four_dimensional_pocket = nil
end

Event.register("base.on_init_save", "Init save (Elona)", init_save)

local function decrease_nutrition(chara, params, result)
   if not chara:is_player() then
      return result -- TODO nil counts as no modifying result
   end

   local nutrition = chara:calc("nutrition")
   if nutrition < 2000 then
      if nutrition < 1000 then
         chara:damage_hp(Rand.rnd(2) + chara:calc("max_hp") / 50, "elona.hunger")
         if save.elona_sys.awake_hours % 10 == 0 then
            -- interrupt action
            if Rand.one_in(50) then
               Effect.modify_weight(chara, -1)
            end
         end
      end
      result.regeneration = false
   end

   return result
end

Event.register("base.on_chara_turn_end",
               "Decrease nutrition",
               decrease_nutrition)

local function play_default_map_music(map, _, music_id)
   if map:has_type("field") then
      return "none"
   end
   if map:has_type("town") then
      music_id = "elona.town1"
   end
   if map:has_type("player_owned") then
      music_id = "elona.home"
   end
   if map:calc("music") then
      music_id = map:calc("music")
   end
   if map:has_type("dungeon") then
      local choices = {
         "elona.dungeon1",
         "elona.dungeon2",
         "elona.dungeon3",
         "elona.dungeon4",
         "elona.dungeon5",
         "elona.dungeon6"
      }
      local hour = World.date().hour
      music_id = choices[hour % 6 + 1]
   end

   if music_id == nil or map:has_type("world_map") then
      local choices = {
         "elona.field1",
         "elona.field2",
         "elona.field3",
      }
      local day = World.date().day
      music_id = choices[day % 3 + 1]
   end

   return music_id
end

Event.register("elona_sys.calc_map_music", "Play default map music",
               play_default_map_music)

local function calc_wand_success(chara, params)
   local magic = data["elona_sys.magic"]:ensure(params.magic_id)
   local item = params.item

   if not chara:is_player() or item:calc("is_zap_always_successful") then
      return true
   end

   local magic_device = chara:skill_level("elona.magic_device")

   local success
   if magic.type == "magic" then
      success = false

      local skill = magic_device * 20 + 100
      if item:calc("curse_state") == "blessed" then
         skill = skill * 125 / 100
      end
      if Effect.is_cursed(item:calc("curse_state")) then
         skill = skill * 50 / 100
      elseif Rand.one_in(2) then
         success = true
      end
      if Rand.rnd(magic.difficulty + 1) / 2 <= skill then
         success = true
      end
   else
      success = true
   end

   if Rand.one_in(30) then
      success = false
   end

   return success
end
Event.register("elona.calc_wand_success", "Default", calc_wand_success)

local function calc_exp_modifier(target)
   local map = target:current_map()
   return 1 + ((target:calc("is_hung_on_sand_bag") and 15) or 0)
      + ((target:calc("splits") and 1) or 0)
      + ((target:calc("splits2") and 1) or 0)
      + (map:calc("exp_modifier") or 0)
end

local function proc_on_physical_attack_miss(chara, params)
   local exp_modifier = calc_exp_modifier(params.target)
   local attack_skill = chara:skill_level(params.attack_skill)
   local target_evasion = params.target:skill_level("elona.evasion")
   if attack_skill > target_evasion or Rand.one_in(5) then
      local exp = math.clamp(attack_skill - target_evasion / 2 + 1, 1, 20) / exp_modifier
      Skill.gain_skill_exp(params.target, "elona.evasion", exp, 0, 4)
      Skill.gain_skill_exp(params.target, "elona.greater_evasion", exp, 0, 4)
   end
end
Event.register("elona.on_physical_attack_miss", "Gain evasion experience", proc_on_physical_attack_miss, 100000)

local function proc_on_physical_attack(chara, params)
   local exp_modifier = calc_exp_modifier(params.target)
   local base_damage = params.base_damage
   local attack_skill = params.attack_skill

   if params.hit == "critical" then
      Skill.gain_skill_exp(chara, "elona.eye_of_mind", 60 / exp_modifier, 2)
   end

   if base_damage > chara:calc("max_hp") / 20
      or base_damage > chara:skill_level("elona.healing")
      or Rand.one_in(5)
   then
      local attack_skill_exp = math.clamp(chara:skill_level("elona.evasion") * 2 - chara:skill_level(attack_skill) + 1, 5, 50) / exp_modifier
      Skill.gain_skill_exp(chara, attack_skill, attack_skill_exp, 0, 4)

      if not params.is_ranged then
         Skill.gain_skill_exp(chara, "elona.tactics", 20 / exp_modifier, 0, 4)
         if chara:calc("is_wielding_two_handed") then
            Skill.gain_skill_exp(chara, "elona.two_handed", 20 / exp_modifier, 0, 4)
         end
         if chara:calc("is_dual_wielding") then
            Skill.gain_skill_exp(chara, "elona.dual_wield", 20 / exp_modifier, 0, 4)
         end
      elseif attack_skill == "elona.throwing" then
         Skill.gain_skill_exp(chara, "elona.tactics", 10 / exp_modifier, 0, 4)
      else
         Skill.gain_skill_exp(chara, "elona.marksman", 25 / exp_modifier, 0, 4)
      end

      -- mount

      local target = params.target
      if Chara.is_alive(target) then
         local exp = math.clamp(250 * base_damage / target:calc("max_hp") + 1, 3, 100) / exp_modifier
         Skill.gain_skill_exp(target, target:calc("armor_class"), exp, 0, 5)
         if target:calc("is_wielding_shield") then
            Skill.gain_skill_exp(target, "elona.shield", 40 / exp_modifier, 0, 4)
         end
      end
   end
end
Event.register("elona.on_physical_attack_hit", "Gain skill experience", proc_on_physical_attack, 100000)

local function proc_weapon_enchantments(chara, params)
   if params.weapon then
      ElonaAction.proc_weapon_enchantments(chara, params.weapon, params.target)
   end
end
Event.register("elona.on_physical_attack_hit", "Proc weapon enchantments", proc_weapon_enchantments, 200000)

local function proc_cut_counterattack(chara, params)
   local cut = params.target:calc("cut_counterattack") or 0
   if cut > 0 and not params.is_ranged then
      chara:damage_hp(params.damage * cut / 100 + 1, params.target, {element="elona.cut", element_power=100})
   end
end
Event.register("elona.on_physical_attack_hit", "Proc cut counterattack", proc_cut_counterattack, 300000)
