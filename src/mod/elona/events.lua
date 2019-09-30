local Chara = require("api.Chara")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Resolver = require("api.Resolver")
local ElonaAction = require("mod.elona.api.ElonaAction")
local ElonaCommand = require("mod.elona.api.ElonaCommand")

--
--
-- Commands
--
--

Gui.bind_keys {
   b = function(me)
      return ElonaCommand.bash(me)
   end,
   e = function(me)
      return ElonaCommand.eat(me)
   end,
   i = function(me)
      return ElonaCommand.dig(me)
   end
}

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

      if params.attacker and params.attacker:is_player() and false then
         retreats = false
      end

      if retreats then
         assert(chara:set_effect_turns("elona.fear", Rand.rnd(20) + 5))
         Gui.mes_visible(chara.uid .. " runs away in fear. ", chara.x, chara.y, "Blue")
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
   if chara:calc("explodes") then
      local chance = chara:calc("explode_chance") or Rand.one_in_percent(3)
      if Rand.percent_chance(chance) then
         chara.will_explode_soon = true
         Gui.mes("*click*")
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
         Gui.play_sound("base.Heart1")
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

local Skill = require("mod.elona_sys.api.Skill")

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
   local race_data = Resolver.run("elona.race", {}, { chara = chara })
   local class_data = Resolver.run("elona.class", {}, { chara = chara })
   chara:mod_base_with(race_data, "merge")
   chara:mod_base_with(class_data, "merge")
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
end

Event.register("base.on_build_chara",
               "Init chara_defaults", init_chara_defaults)


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
      local resistance = chara:resist_level(element._id)
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

local function vorpal_damage(chara, params, result)
   if params.element and params.element._id == "elona.vorpal" then
      result = params.original_damage
   end
   return result
end

Event.register("base.hook_calc_damage",
               "Proc vorpal damage", vorpal_damage)

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


local function bump_into_chara(player, params, result)
   local on_cell = params.chara
   local reaction = player:reaction_towards(on_cell)

   if reaction > 0 then
      if true then
         if player:swap_places(on_cell) then
            Gui.mes("You switch places with " .. on_cell.uid .. ".")
            Gui.set_scroll()
         end
      end
      return "turn_end"
   end

   -- TODO: relation as -1
   if reaction < 0 then
      player:set_target(on_cell)
      ElonaAction.melee_attack(player, on_cell)
      Gui.set_scroll()
      return "turn_end"
   end

   return result
end

Event.register("elona_sys.on_player_bumped_into_chara",
               "Attack/swap position", bump_into_chara)
