local Const = require("api.Const")
local Rand = require("api.Rand")
local Map = require("api.Map")
local Chara = require("api.Chara")
local Event = require("api.Event")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Anim = require("mod.elona_sys.api.Anim")
local ICharaEquip = require("api.chara.ICharaEquip")
local Enum = require("api.Enum")

local Skill = {}

function Skill.iter_attributes()
   return data["base.skill"]:iter():filter(function(s) return s.type == "stat" end)
end

function Skill.iter_base_attributes()
   return Skill.iter_attributes():filter(function(s) return s._id ~= "elona.stat_speed" and s._id ~= "elona.stat_luck" end)
end

function Skill.iter_resistances()
   return data["base.element"]:iter():filter(function(e) return e.can_resist end)
end

function Skill.iter_skills()
   return data["base.skill"]:iter():filter(function(s) return s.type == "skill" or s.type == "skill_action" or s.type == "weapon_proficiency" end)
end

function Skill.iter_normal_skills()
   return data["base.skill"]:iter():filter(function(s) return s.type == "skill" or s.type == "skill_action" end)
end

function Skill.iter_weapon_proficiencies()
   return data["base.skill"]:iter():filter(function(s) return s.type == "weapon_proficiency" end)
end

function Skill.iter_spells()
   return data["base.skill"]:iter():filter(function(s) return s.type == "spell" end)
end

function Skill.iter_actions()
   return data["base.skill"]:iter():filter(function(s) return s.type == "action" or s.type == "skill_action" end)
end

--- @hsp randAttb()
function Skill.random_base_attribute()
   return Rand.choice(Skill.iter_base_attributes())._id
end

function Skill.random_attribute()
   return Rand.choice(Skill.iter_attributes())._id
end

function Skill.random_skill()
   return Rand.choice(Skill.iter_skills())._id
end

function Skill.random_resistance()
   return Rand.choice(Skill.iter_resistances())._id
end

function Skill.random_resistance_by_rarity()
   local element_data = data["base.element"]:ensure(Skill.random_resistance())
   for _ = 1, element_data.rarity do
      local other_element = data["base.element"]:ensure(Skill.random_resistance())
      if other_element.rarity < element_data.rarity and Rand.one_in(2) then
         element_data = other_element
      end
   end
   return element_data._id
end

function Skill.calc_initial_potential(skill, level, knows_skill)
   local p

   -- >>>>>>>> shade2/calculation.hsp:947 	if sid >= headWeaponSkill{ ..
   if skill.type == "stat" then
      p = math.min(level * 20, 400)
   else
      p = level * 5
      if knows_skill then
         p = p + 50
      else
         p = p + 100
      end
   end
   -- <<<<<<<< shade2/calculation.hsp:953 		} ..

   return p
end

function Skill.calc_initial_decayed_potential(base_potential, chara_level)
   -- >>>>>>>> shade2/calculation.hsp:955 	if cLevel(c)>1	:p=int(pow@(growthDec,cLevel(c))*p ..
   if chara_level <= 1 then
      return base_potential
   end

   return math.floor(math.exp(math.log(Const.POTENTIAL_DECAY_RATE) * chara_level) * base_potential)
   -- <<<<<<<< shade2/calculation.hsp:955 	if cLevel(c)>1	:p=int(pow@(growthDec,cLevel(c))*p ..
end

function Skill.calc_initial_skill_level(skill, initial_level, original_level, chara_level, chara)
   -- >>>>>>>> shade2/calculation.hsp:945 #deffunc skillInit int sid,int c,int a ..
   local sk = data["base.skill"]:ensure(skill)

   -- if not chara:has_skill(skill) then
   --    chara:set_base_skill(skill, 0, 0, 0)
   -- end
   -- local my_skill = chara:calc("skills")[skill]

   local potential
   local level = original_level

   if sk.calc_initial_potential then
      potential = sk.calc_initial_potential(initial_level, chara)
   else
      potential = Skill.calc_initial_potential(sk, initial_level, original_level == 0)
   end
   if sk.calc_initial_level then
      level = sk.calc_initial_level(initial_level, chara)
   else
      level = math.floor(potential * potential * chara_level / 45000 + initial_level + chara_level / 3)
   end

   potential = Skill.calc_initial_decayed_potential(potential, chara_level)

   if sk.calc_final then
      local t = sk.calc_final(initial_level, chara) or {}
      level = t.level or level
      potential = t.potential or potential
   end

   potential = math.max(1, potential)

   level = math.clamp(level, 0, Const.MAX_SKILL_LEVEL)

   return {
      level = level,
      potential = potential
   }
   -- <<<<<<<< shade2/calculation.hsp:961 	return ..
end

function Skill.calc_related_skill_exp(exp, exp_divisor)
   return exp / (2 + exp_divisor)
end

function Skill.calc_skill_exp(base_exp, potential, skill_level, buff)
   buff = buff or 0
   local exp = base_exp * potential / (100 + skill_level * 15)
   if buff > 0 then
      exp = exp * (100 + buff) / 100
   end
   return exp
end

local function get_skill_buff(chara, skill_id)
   local buffs = chara.temp.growth_buffs or {}
   return buffs[skill_id] or 0
end

function Skill.calc_chara_exp_from_skill_exp(required_exp, level, skill_exp, exp_divisor)
   return Rand.rnd(required_exp * skill_exp / 1000 / (level + exp_divisor) + 1) + Rand.rnd(2)
end

function Skill.modify_potential_from_level(chara, skill, level_delta)
   local potential = chara:skill_potential(skill)
   if level_delta > 0 then
      for _=0,level_delta do
         potential = math.max(math.floor(potential * Const.POTENTIAL_DECAY_RATE), 1)
      end
   elseif level_delta < 0 then
      for _=0,-level_delta do
         potential = math.min(math.floor(potential * (1.0 + (1.0 - Const.POTENTIAL_DECAY_RATE))) + 1, 400)
      end
   end
   chara.skills["base.skill:" .. skill].potential = potential
   return potential
end

-- TODO replace with ICharaSkills:mod_skill_potential()
function Skill.modify_potential(chara, skill, delta)
   local potential = math.clamp(math.floor(chara:skill_potential(skill) + delta), 2, 400)
   chara.skills["base.skill:" .. skill].potential = potential
end

local function skill_change_text(chara, skill_id, is_increase)
   local text
   if is_increase then
      text = I18N.get("skill." .. skill_id .. ".increase", chara)
   else
      text = I18N.get("skill." .. skill_id .. ".decrease", chara)
   end

   if text then
      return text
   end

   if is_increase then
      return I18N.get("skill.default", chara, "ability." .. skill_id .. ".name")
   else
      return I18N.get("skill.default.decrease", chara, "ability." .. skill_id .. ".name")
   end
end

local function proc_leveling(chara, skill, new_exp, level)
   -- >>>>>>>> shade2/module.hsp:312 	if exp>=1000{ ..
   local map = chara:current_map()
   if new_exp >= 1000 then
      local level_delta = math.floor(new_exp / 1000)
      new_exp = new_exp % 1000
      level = level + level_delta
      local potential = Skill.modify_potential_from_level(chara, skill, level_delta)
      chara:set_base_skill(skill, level, potential, new_exp)
      if Map.is_in_fov(chara.x, chara.y, map) then
         local color = "White"
         if chara:is_in_player_party() then
            Gui.play_sound("base.ding3")
            Gui.mes_alert()
            color = "Green"
         end
         Gui.mes_c(skill_change_text(chara, skill, true), color)
      end
      chara:refresh()
      return level_delta
   elseif new_exp < 0 then
      local level_delta = math.floor(-new_exp / 1000 + 1)
      new_exp = 1000 + new_exp % 1000
      if level - level_delta < 1 then
         level_delta = level - 1
         if level == 1 and level_delta == 0 then
            new_exp = 0
         end
      end

      level = level - level_delta
      local potential = Skill.modify_potential_from_level(chara, skill, -level_delta)
      chara:set_base_skill(skill, level, potential, new_exp)
      if Map.is_in_fov(chara.x, chara.y, map) and level_delta ~= 0 then
         Gui.mes_c(skill_change_text(chara, skill, false), "Red")
         Gui.mes_alert()
      end
      chara:refresh()
      return level_delta
   else
      chara:set_base_skill(skill, level, nil, new_exp)
      return 0
   end
   -- <<<<<<<< shade2/module.hsp:346 	sdata@(sID+rangeSdata,c)=limit(lv,0,2000)*1000000 ..
end

--- @hsp skillMod skill, chara, exp
function Skill.gain_fixed_skill_exp(chara, skill, exp)
-- >>>>>>>> shade2/module.hsp:234 	#deffunc skillMod int sid,int c,int a ..
   data["base.skill"]:ensure(skill)

   local level = chara:base_skill_level(skill)
   local potential = chara:skill_potential(skill)
   local new_exp = chara:skill_experience(skill) + exp

   if potential == 0 then
      return
   end

   local level_delta = proc_leveling(chara, skill, new_exp, level, potential)

   chara:emit("elona_sys.on_gain_skill_exp", { skill_id = skill, base_exp_amount = exp, actual_exp_amount = exp })

   return level_delta
   -- <<<<<<<< shade2/module.hsp:281 	return ..
end

--- @hsp skillExp skill chara base_exp exp_divisor_stat exp_divisor_level
function Skill.gain_skill_exp(chara, skill, base_exp, exp_divisor_stat, exp_divisor_level)
   -- >>>>>>>> shade2/module.hsp:283 	#deffunc skillExp int sid,int c,int a,int refExpD ..
   exp_divisor_stat = exp_divisor_stat or 0
   exp_divisor_level = exp_divisor_level or 0

   local skill_data = data["base.skill"]:ensure(skill)

   if not chara:has_skill(skill) then return end
   if base_exp == 0 then return end

   if skill_data.related_skill then
      local exp = Skill.calc_related_skill_exp(base_exp, exp_divisor_stat)
      Skill.gain_skill_exp(chara, skill_data.related_skill, exp)
   end

   local level = chara:base_skill_level(skill)
   local potential = chara:skill_potential(skill)
   if potential == 0 then return end

   local exp
   if base_exp > 0 then
      local buff = get_skill_buff(chara, skill)
      exp = Skill.calc_skill_exp(base_exp, potential, level, buff)
      if exp == 0 then
         if Rand.one_in(level / 10 + 1) then
            exp = 1
         else
            return
         end
      end
   else
      exp = base_exp
   end

   local map = chara:current_map()
   if map then
      local exp_divisor = map:calc("exp_divisor")
      if exp_divisor then
         exp = exp / exp_divisor
      end
   end

   if exp > 0 and skill_data.apply_exp_divisor and exp_divisor_level <= 1000 then
      local lvl_exp = Skill.calc_chara_exp_from_skill_exp(chara:calc("required_experience"), chara:calc("level"), exp, exp_divisor_level)
      chara.experience = chara.experience + lvl_exp
      if chara:is_player() then
         chara.sleep_experience = chara.sleep_experience + lvl_exp
      end
   end

   local new_exp = exp + chara:skill_experience(skill)
   local level_delta = proc_leveling(chara, skill, new_exp, level)

   chara:emit("elona_sys.on_gain_skill_exp", { skill_id = skill, base_exp_amount = base_exp, actual_exp_amount = exp })

   return level_delta, exp
   -- <<<<<<<< shade2/module.hsp:349 	#defcfunc calcFame int c,int per ..
end

local function get_random_body_part()
   -- >>>>>>>> shade2/calculation.hsp:33 	gainBody bodyNeck,7 ...
   if Rand.one_in(7) then
      return "elona.neck"
   end
   if Rand.one_in(9) then
      return "elona.back"
   end
   if Rand.one_in(8) then
      return "elona.hand"
   end
   if Rand.one_in(4) then
      return "elona.ring"
   end
   if Rand.one_in(6) then
      return "elona.arm"
   end
   if Rand.one_in(5) then
      return "elona.waist"
   end
   if Rand.one_in(5) then
      return "elona.leg"
   end

   return "elona.head"
   -- <<<<<<<< shade2/calculation.hsp:40 	gainBody bodyHead,1 ..
end

local function refresh_speed_correction(chara)
   -- XXX: "blocked" body parts from things like ether disease still get counted
   -- towards the speed penalty.
   local count = chara:iter_all_body_parts():length()

   if count > 13 then
      chara.speed_correction = (count - 13) + 5
   else
      chara.speed_correction = 0
   end
end

function Skill.gain_random_body_part(chara, show_message)
   -- NOTE: is different in vanilla, checks for openness of slot?

   local body_part = get_random_body_part();
   chara:add_body_part(body_part)

   if show_message then
      Gui.mes_c("chara_status.gain_new_body_part",
                "Green",
                chara,
                I18N.get("ui.body_part." .. body_part))
   end

   refresh_speed_correction(chara)
end

function Skill.refresh_speed(chara)
   chara.current_speed = math.floor(chara:skill_level("elona.stat_speed") + math.clamp(100 - chara:calc("speed_correction"), 0, 100) / 100)

   chara.current_speed = math.max(chara.current_speed, 10)

   chara.speed_percentage_in_next_turn = 0
   local spd_perc = 0

   if not chara:is_player() then
      return
   end

   local has_mount = false
   if not has_mount then
      local nutrition = math.floor(chara:calc("nutrition") / 1000 * 1000)
      if nutrition < Const.HUNGER_THRESHOLD_STARVING then
         spd_perc = spd_perc - 30
      end
      if nutrition < Const.HUNGER_THRESHOLD_HUNGRY then
         spd_perc = spd_perc - 10
      end
      if chara.stamina < Const.FATIGUE_THRESHOLD_HEAVY then
         spd_perc = spd_perc - 30
      end
      if chara.stamina < Const.FATIGUE_THRESHOLD_MODERATE then
         spd_perc = spd_perc - 20
      end
      if chara.stamina < Const.FATIGUE_THRESHOLD_LIGHT then
         spd_perc = spd_perc - 10
      end
   end
   if chara.inventory_weight_type >= Enum.Burden.Heavy then
      spd_perc = spd_perc - 50
   end
   if chara.inventory_weight_type == Enum.Burden.Moderate then
      spd_perc = spd_perc - 30
   end
   if chara.inventory_weight_type == Enum.Burden.Light then
      spd_perc = spd_perc - 10
   end

   local map = chara:current_map()
   if map and map:has_type({"world_map", "field"}) then
      local cargo_weight = chara:calc("cargo_weight")
      local max_cargo_weight = chara:calc("max_cargo_weight")
      if cargo_weight > max_cargo_weight then
         spd_perc = spd_perc - 25 + 25 * cargo_weight / (max_cargo_weight + 1)
      end
   end

   chara.speed_percentage_in_next_turn = spd_perc
end

function Skill.apply_speed_percentage(chara, next_turn)
   if next_turn then
      chara.speed_percentage = chara.speed_percentage_in_next_turn
   end

   local spd = math.floor(chara.current_speed * (100 + chara.speed_percentage) / 100)
   spd = math.max(spd, 10)

   return spd
end

function Skill.gain_level(chara, show_message)
   chara.experience = math.max(chara.experience - chara.required_experience, 0)
   chara.level = chara.level + 1

   if show_message then
      if chara:is_player() then
         Gui.mes_c("chara.gain_level.self", "Green", chara, chara.level)
      else
         Gui.mes_c("chara.gain_level.other", "Green", chara)
      end
   end

   local skill_bonus = 5 + (100 + chara:base_skill_level("elona.stat_learning") + 10) / (300 + chara.level * 15) + 1

   if chara:is_player() then
      if chara.level % 5 == 0 then
         if chara.max_level < chara.level and chara.level <= 50 then
            chara.aquirable_feat_count = chara.aquirable_feat_count + 1
         end
      end

      skill_bonus = skill_bonus + chara:trait_level("elona.perm_skill_point")
   end

   chara.skill_bonus = chara.skill_bonus + skill_bonus
   chara.total_skill_bonus = chara.total_skill_bonus + skill_bonus

   if chara:has_trait("elona.perm_chaos_shape") then
      if chara.level < 37 and chara.level % 3 == 0 and chara.max_level < chara.level then
         Skill.gain_random_body_part(chara, true)
      end
   end

   if chara.max_level < chara.level then
      chara.max_level = chara.level
   end

   if not chara:is_in_player_party() then
      Skill.grow_primary_skills(chara, show_message)
   end

   chara.required_experience = Skill.calc_required_experience(chara)
   chara:refresh()
end

function Skill.grow_primary_skills(chara)
   local function grow(skill)
      chara:mod_base_skill_level(skill, Rand.rnd(3), "add")
   end

   for _, stat in Skill.iter_attributes() do
      grow(stat._id)
   end

   -- Grow some skills available on all characters (by default: evasion, martial arts, bow)
   local main_skills = data["base.skill"]:iter():filter(function(s) return s.is_main_skill end)

   for _, skill in main_skills:unwrap() do
      grow(skill._id)
   end
end

function Skill.calc_required_experience(chara)
   local lv = math.clamp(chara.level, 1, 200)
   return math.clamp(lv * (lv + 1) * (lv + 2) * (lv + 3) + 3000, 0, 100000000)
end

-- >>>>>>>> shade2/chara_func.hsp:130 #defcfunc impLevel int a ..
function Skill.impression_level(impression)
   if     impression < 10                             then return 0
   elseif impression < Const.IMPRESSION_HATE          then return 1
   elseif impression < Const.IMPRESSION_NORMAL - 10   then return 2
   elseif impression < Const.IMPRESSION_AMIABLE       then return 3
   elseif impression < Const.IMPRESSION_FRIEND        then return 4
   elseif impression < Const.IMPRESSION_FELLOW        then return 5
   elseif impression < Const.IMPRESSION_MARRY         then return 6
   elseif impression < Const.IMPRESSION_SOULMATE      then return 7
   else                                                    return 8
   end
end
-- <<<<<<<< shade2/chara_func.hsp:139 	return 8 ..

--- @example Skill.modify_impression(tc, 5)
--- @hsp modImp tc,5
function Skill.modify_impression(chara, delta)
   -- >>>>>>>> shade2/chara_func.hsp:141 #deffunc modImp int c,int a ..
   delta = math.floor(delta)
   local level = Skill.impression_level(chara.impression)
   if delta >= 0 then
      delta = delta * 100 / (50 + level * level * level)
      if delta == 0 and level < Rand.rnd(10) then
         delta = 1
      end
   end

   chara.impression = math.floor(chara.impression + delta)
   local new_level = Skill.impression_level(chara.impression)
   if level > new_level then
      Gui.mes_c("chara.impression.lose", "Purple", chara, "ui.impression._" .. new_level)
   elseif new_level > level and chara:relation_towards(Chara.player()) > Enum.Relation.Enemy then
      Gui.mes_c("chara.impression.gain", "Green", chara, "ui.impression._" .. new_level)
   end
   -- <<<<<<<< shade2/chara_func.hsp:155 	return ..
end

--
--
-- Events
--
--

local function refresh_max_inventory_weight(chara)
   local weight = chara:calc("inventory_weight")
   local mod = math.floor(weight * (100 - chara:trait_level("elona.ether_gravity") * 10 +
                                       chara:trait_level("elona.ether_feather") * 20) / 100)
   chara:mod("inventory_weight", mod, "set")

   chara:mod("max_inventory_weight",
             chara:skill_level("elona.stat_strength") * 500 +
                chara:skill_level("elona.stat_constitution") * 250 +
                chara:skill_level("elona.weight_lifting") * 2000 +
                45000, "set")
end

Event.register("base.on_refresh_weight", "refresh max inventory weight", refresh_max_inventory_weight)

local function refresh_weight(chara)
   local weight = chara:calc("inventory_weight")
   local max_weight = chara:calc("max_inventory_weight")

   -- >>>>>>>> shade2/calculation.hsp:1315 	repeat 1 ...
   if weight > max_weight * 2 then
      chara.inventory_weight_type = Enum.Burden.Max
   elseif weight > max_weight then
      chara.inventory_weight_type = Enum.Burden.Heavy
   elseif weight > max_weight / 4 * 3  then
      chara.inventory_weight_type = Enum.Burden.Moderate
   elseif weight > max_weight / 2 then
      chara.inventory_weight_type = Enum.Burden.Light
   else
      chara.inventory_weight_type = Enum.Burden.None
   end

   if config.base.debug_no_weight then
      chara.inventory_weight_type = Enum.Burden.None
   end

   Skill.refresh_speed(chara)
   -- <<<<<<<< shade2/calculation.hsp:1326 	return ..
end

Event.register("base.on_refresh_weight", "apply weight type", refresh_weight)

local function calc_speed(chara)
   return Skill.apply_speed_percentage(chara, true)
end

Event.register("base.on_calc_speed", "calc speed", calc_speed)

function Skill.calc_spell_mp_cost(skill_id, chara)
   local skill_entry = data["base.skill"]:ensure(skill_id)
   local cost
   if skill_entry.calc_mp_cost then
      cost = skill_entry:calc_mp_cost(chara)
   elseif chara:is_player() then
      cost = skill_entry.cost * (100 + chara:skill_level(skill_id) * 3) / 100 + chara:skill_level(skill_id) / 8
   else
      cost = skill_entry.cost * (50 + chara:calc("level") * 3) / 100
   end
   return math.floor(cost)
end

function Skill.calc_spell_stock_cost(skill_id, chara)
   local skill_entry = data["base.skill"]:ensure(skill_id)
   local cost = skill_entry.cost * 200 / (chara:skill_level(skill_id) * 3 + 100)
   cost = math.max(cost, skill_entry.cost / 5)
   cost = Rand.rnd(cost / 2 + 1) + cost / 2
   return math.floor(cost)
end

function Skill.calc_spell_success_chance(skill_id, chara)
   local skill_entry = data["base.skill"]:ensure(skill_id)

   -- TODO riding
   local factor = 4
   local armor_class = chara:calc("armor_class")
   if armor_class == "elona.heavy_armor" then
      factor = 17 - chara:skill_level("elona.heavy_armor") / 5
   elseif armor_class == "elona.medium_armor" then
      factor = 12 - chara:skill_level("elona.medium_armor") / 5
   end
   factor = math.max(factor, 4)
   if skill_entry.calc_spell_failure_factor then
      factor = skill_entry:calc_spell_failure_factor(chara, factor)
   end

   local chance = 90 + chara:skill_level(skill_id) - (skill_entry.difficulty * factor / (5 + chara:skill_level("elona.casting") * 4))

   if armor_class == "elona.heavy_armor" then
      chance = math.min(chance, 80)
   elseif armor_class == "elona.medium_armor" then
      chance = math.min(chance, 92)
   else
      chance = math.min(chance, 100)
   end

   if chara:calc("is_dual_wielding") then
      chance = chance - 6
   end

   if chara:calc("is_wielding_shield") then
      chance = chance - 12
   end

   chance = math.clamp(chance, 0, 100)

   return math.floor(chance)
end

function Skill.calc_spell_power(skill_id, chara)
   -- >>>>>>>> shade2/calculation.hsp:867 #defcfunc calcSpellPower int id,int c ...
   local skill_entry = data["base.skill"]:ensure(skill_id)
   if skill_entry.type ~= "spell" then
      -- NOTE: In vanilla, power was calculated by multipying the enum
      -- value of the skill's type (bolt, arrow, ball, etc.) and
      -- adding 10. This means bolt spells were the least powerful and
      -- ball spells were more powerful. This is changed here (and in
      -- omake overhaul) to be the skill level of the action or the
      -- character's level.
      if not chara:is_player() then
         return chara:calc("level") * 6 + 10
      end
      if chara:is_player() and chara:has_skill(skill_id) then
         return chara:skill_level(skill_id) * 6 + 10
      end

      return 100
   end

   if chara:is_player() then
      return chara:skill_level(skill_id) * 10 + 50
   end

   -- TODO customize AI spell power
   if not chara:has_skill("elona.casting") and not chara:is_ally() then
      return chara:calc("level") * 6 + 10
   end

   return chara:skill_level("elona.casting") * 6 + 10
   -- <<<<<<<< shade2/calculation.hsp:874 	return sCasting(c)*6+10 ..
end

function Skill.get_dice(skill_id, chara, power)
   local skill_entry = data["base.skill"]:ensure(skill_id)

   local dice = { x = 0, y = 0, bonus = 0, element_power = 0 }
   if skill_entry.effect_id then
      local effect_entry = data["elona_sys.magic"]:ensure(skill_entry.effect_id)
      if effect_entry.dice then
         dice = effect_entry:dice({ source = chara, power = power })
         dice.x = math.floor(dice.x or 0)
         dice.y = math.floor(dice.y or 0)
         dice.bonus = math.floor(dice.bonus or 0)
         dice.element_power = math.floor(dice.element_power or 0)
      end
   end

   return dice
end

function Skill.get_description(skill_id, chara)
   local desc = ""

   local is_buff = false -- TODO
   if is_buff then
      return "turn"
   end

   local skill_entry = data["base.skill"]:ensure(skill_id)

   local power = Skill.calc_spell_power(skill_id, chara)
   local dice = Skill.get_dice(skill_id, chara, power)

   if skill_entry.calc_desc then
      return skill_entry.calc_desc(chara, power, dice)
   elseif dice.x > 0 then
      desc = desc .. ("%dd%d"):format(dice.x, dice.y)
      if dice.bonus > 0 then
         desc = desc .. ("+%d"):format(dice.bonus)
      end
   else
      desc = desc .. ("%s%s"):format(I18N.get("ui.spell.power"), power)
   end
   desc = desc .. " "

   return desc .. I18N.get("ability." .. skill_id .. ".description")
end

function Skill.gain_skill(chara, skill_id, initial_level, initial_stock)
   local skill = data["base.skill"]:ensure(skill_id)

   chara.skills["base.skill:" .. skill_id] = chara.skills["base.skill:" .. skill_id] or
      {
         level = 0,
         potential = 0,
         experience = 0,
      }

   if skill.type == "spell" and chara:is_player() then
      initial_stock = math.floor(initial_stock or 0)
      chara.spell_stocks[skill_id] = (chara.spell_stocks[skill_id] or 0) + initial_stock
      Skill.modify_potential(chara, skill_id, 1)
   end

   if chara:base_skill_level(skill_id) ~= 0 and skill.type ~= "spell" then
      Skill.modify_potential(chara, skill_id, 20)
      return
   end

   local new_level = math.max(chara:base_skill_level(skill_id) + (initial_level or 0), 1)
   if skill.type == "spell" then
      Skill.modify_potential(chara, skill_id, 200)
   else
      Skill.modify_potential(chara, skill_id, 50)
   end
   chara.skills["base.skill:" .. skill_id].level = new_level
   chara:refresh()
end

function Skill.modify_resist_level(chara, element_id, delta, no_message)
   local level = math.clamp(chara:base_resist_level(element_id) + delta, 50, 200)

   if not no_message then
      if delta >= 50 then
         Gui.mes_c("element.resist.gain." .. element_id, "Green", chara)
      elseif delta <= -50 then
         Gui.mes_c("element.resist.lose." .. element_id, "Red", chara)
      end
   end

   if not chara:has_resist(element_id) then
      chara:gain_resist(element_id)
   end
   chara.skills["base.element:" .. element_id].level = level

   if not no_message then
      Gui.play_sound("base.atk_elec", chara.x, chara.y)
      local cb = Anim.load("elona.anim_elec", chara.x, chara.y)
      Gui.start_draw_callback(cb)
   end

   chara:refresh()
end

--- Takes a map of skill IDs to initial skill levels and a character, and rolls
--- a set of complete skill levels/potentials for that character.
function Skill.roll_skill_levels(chara, skills)
   local result = {}

   local chara_level = chara:calc("level")

   for skill_id, base_level in pairs(skills) do
      local chara_base_level = chara:base_skill_level(skill_id)
      result[skill_id] = Skill.calc_initial_skill_level(skill_id, base_level, chara_base_level, chara_level, chara)
   end

   return result
end

--- Applies the properties and base skill levels of a race for a character.
---
--- As this is based off of the existing skill levels of the character, it
--- should only be run once.
---
--- This is typically run before applying class properties.
---
--- NOTE: This also clears all body parts and reinitializes them to the race's
--- values.
---
--- @see Skill.apply_class_params
function Skill.apply_race_params(chara, race_id)
   local race_data = data["base.race"]:ensure(race_id)

   for k, v in pairs(race_data.properties or {}) do
      if chara[k] == nil then
         chara[k] = v
      end
   end

   local skills = Skill.roll_skill_levels(chara, race_data.skills)
   for skill_id, skill in pairs(skills) do
      local chara_base_level = chara:base_skill_level(skill_id)
      local chara_potential = chara:skill_potential(skill_id)
      chara:set_base_skill(skill_id, chara_base_level + skill.level, chara_potential + skill.potential, 0)
   end

   for trait_id, level in pairs(race_data.traits or {}) do
      chara.traits[trait_id] = { level = level }
   end

   if race_data.resistances then
      for element_id, amount in ipairs(race_data.resistances) do
         chara:mod_resist_level(element_id, amount, "set")
      end
   end

   chara.age = 1
   if race_data.age_min or race_data.age_max then
      chara.age = Rand.between(race_data.age_min or 1, race_data.age_max or 1)
   end
   if Rand.percent_chance(race_data.male_ratio or 50) then
      chara.gender = "male"
   else
      chara.gender = "female"
   end

   -- >>>>>>>> shade2/chara.hsp:518 	cHeight(rc)=cHeight(rc) + rnd(cHeight(rc)/5+1) -  ...
   chara.height = race_data.height or 10
   chara.height = chara.height + Rand.rnd(chara.height / 5 + 1) - Rand.rnd(chara.height / 5 + 1)
   chara.weight = math.floor(chara.height * chara.height * (Rand.rnd(6) + 18) / 10000)
   -- <<<<<<<< shade2/chara.hsp:519 	cWeight(rc)= cHeight(rc)*cHeight(rc)*(rnd(6)+18)/ ..

   -- >>>>>>>> shade2/chara.hsp:341 *set_figure ..
   chara.body_parts = table.deepcopy(race_data.body_parts or {})
   table.insert(chara.body_parts, "elona.ranged")
   table.insert(chara.body_parts, "elona.ammo")
   ICharaEquip.init(chara)
   -- <<<<<<<< shade2/chara.hsp:376 	return ..
end

--- Applies the properties and base skill levels of a class for a character.
---
--- As this is based off of the existing skill levels of the character, it
--- should only be run once.
---
--- This is typically run after applying racial properties.
---
--- @see Skill.apply_race_params
function Skill.apply_class_params(chara, class_id)
   local class_data = data["base.class"]:ensure(class_id)

   for k, v in pairs(class_data.properties or {}) do
      if chara[k] == nil then
         chara[k] = v
      end
   end

   local skills = Skill.roll_skill_levels(chara, class_data.skills)
   for skill_id, skill in pairs(skills) do
      local chara_base_level = chara:base_skill_level(skill_id)
      local chara_potential = chara:skill_potential(skill_id)
      chara:set_base_skill(skill_id, chara_base_level + skill.level, chara_potential + skill.potential, 0)
   end
end

return Skill
