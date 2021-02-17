local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Event = require("api.Event")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Map = require("api.Map")

local function retreat_in_fear(chara, params)
   -- >>>>>>>> shade2/chara_func.hsp:1535 		if cHp(tc)<cMhp(tc)/5:if tc!pc:if cFear(tc)=0:if ..
   if chara.hp < chara:calc("max_hp") / 5 then
      if chara:is_player() or chara:has_effect("elona.fear") then
         return
      end

      if chara:is_immune_to_effect("elona.fear") then
         return
      end

      local retreats = (params.damage * 100 / chara:calc("max_hp") + 10) > Rand.rnd(200)

      if params.attacker and params.attacker:has_trait("elona.no_fear") then
         retreats = false
      end

      if retreats then
         assert(chara:set_effect_turns("elona.fear", Rand.rnd(20) + 5))
         Gui.mes_c_visible("damage.runs_away_in_terror", chara.x, chara.y, "Blue", chara)
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:1539 			} ..
end

Event.register("base.on_damage_chara",
               "Retreat in fear", retreat_in_fear)

local function disturb_sleep(chara, params)
   -- >>>>>>>> shade2/chara_func.hsp:1563 		if cSleep(tc)!0: if (ele!rsResMind)&(ele!rsResNe ...
   if not params.element or not params.element.preserves_sleep then
      if chara:has_effect("elona.sleep") then
         chara:remove_effect("elona.sleep")
         Gui.mes("damage.sleep_is_disturbed", chara)
      end
   end
   if params.attacker then
      params.attacker.noise = 100
      params.attacker:act_hostile_towards(chara)
   end
   -- <<<<<<<< shade2/chara_func.hsp:1567 			} ..
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
      -- >>>>>>>> shade2/chara_func.hsp:1578 		if cBit(cTemper,tc):if dmgType!dmgSub:if cAngry( ...
      if not chara:has_effect("elona.fury") then
         if Rand.one_in(20) then
            Gui.mes_c_visible("damage.is_engulfed_in_fury", chara, "Blue")
            chara:set_effect_turns("elona.fury", Rand.rnd(30) + 15)
         end
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:1581 		} ..
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
      for _, ally in chara:iter_other_party_members() do
         if Chara.is_alive(ally)
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

local function calc_damage_fury(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1441 	dmg = dmgOrg * (1+(cAngry(tc)>0)) ..
   if chara:has_effect("elona.fury") then
      result = result * 2
   end
   if params.attacker and params.attacker:has_effect("elona.fury") then
      result = result * 2
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1442 	if dmgSource>=0 : if cAngry(dmgSource)>0:dmg*=2 ..
end

Event.register("base.hook_calc_damage",
               "Proc fury", calc_damage_fury)


local function calc_damage_resistance(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1444 	if (ele=false)or(ele>=tailResist){ ..
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
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1454 		} ..
end

Event.register("base.hook_calc_damage",
               "Proc elemental resistance", calc_damage_resistance)

local function calc_element_damage(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1458 	if cWet(tc)>0{ ..
   local element = params.element
   if element and element.on_modify_damage then
      result = element.on_modify_damage(chara, result)
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1461 		} ..
end

Event.register("base.hook_calc_damage",
               "Proc elemental damage", calc_element_damage)

local function is_immune_to_elemental_damage(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1463 	if ele:if ele!rsResMagic:if cBit(cResEle,tc):dmg= ..
   if chara:calc("is_immune_to_elemental_damage") then
      if params.element and params.element._id ~= "elona.magic" then
         result = 0
      end
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1463 	if ele:if ele!rsResMagic:if cBit(cResEle,tc):dmg= ..
end

Event.register("base.hook_calc_damage",
               "Proc elemental damage immunity", is_immune_to_elemental_damage)

local function is_metal_damage(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1464 	if cBit(cMetal,tc):dmg=rnd(dmg/10+2) ..
   if chara:calc("is_metal") then
      result = Rand.rnd(result / 10 + 2)
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1464 	if cBit(cMetal,tc):dmg=rnd(dmg/10+2) ..
end

Event.register("base.hook_calc_damage",
               "Proc is_metal damage", is_metal_damage)

local function proc_contingency(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1465 	if cBit(cContingency,tc):if cHp(tc)-dmg<=0:if cal ..
   if chara.hp - result <= 0 then
      local buff = chara:find_buff("elona.contingency")
      if buff and buff.power >= Rand.rnd(100) then
         result = -result
      end
   end

   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1465 	if cBit(cContingency,tc):if cHp(tc)-dmg<=0:if cal ..
end

Event.register("base.hook_calc_damage",
               "Proc contingency", proc_contingency)

local function proc_damage_immunity(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1466 	if cImmuneDamage(tc)>0:if cImmuneDamage(tc)>rnd(1 ..
   local chance = chara:calc("damage_immunity_rate") or 0
   if chance > 0 and chance > Rand.one_in(100) then
      result = 0
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1466 	if cImmuneDamage(tc)>0:if cImmuneDamage(tc)>rnd(1 ..
end

Event.register("base.hook_calc_damage",
               "Proc damage immunity", proc_damage_immunity)

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

local function calc_exp_modifier(target)
   -- >>>>>>>> shade2/action.hsp:1251 	expModifer=1+cBit(cSandBag,tc)*15+cBit(cSplit,tc) ..
   local map = target:current_map()
   return 1 + ((target:calc("is_hung_on_sandbag") and 15) or 0)
      + ((target:calc("splits") and 1) or 0)
      + ((target:calc("splits2") and 1) or 0)
      + (map:calc("exp_modifier") or 0)
   -- <<<<<<<< shade2/action.hsp:1251 	expModifer=1+cBit(cSandBag,tc)*15+cBit(cSplit,tc) ..
end

local function proc_on_physical_attack_miss(chara, params)
   -- >>>>>>>> shade2/action.hsp:1356 		if (sdata(attackSkill,cc)>sEvade(tc))or(rnd(5)=0 ..
   local exp_modifier = calc_exp_modifier(params.target)
   local attack_skill = chara:skill_level(params.attack_skill)
   local target_evasion = params.target:skill_level("elona.evasion")
   if attack_skill > target_evasion or Rand.one_in(5) then
      local exp = math.clamp(attack_skill - target_evasion / 2 + 1, 1, 20) / exp_modifier
      Skill.gain_skill_exp(params.target, "elona.evasion", exp, 0, 4)
      Skill.gain_skill_exp(params.target, "elona.greater_evasion", exp, 0, 4)
   end
   -- <<<<<<<< shade2/action.hsp:1360 			} ..
end
Event.register("elona.on_physical_attack_miss", "Gain evasion experience", proc_on_physical_attack_miss, 100000)

local function proc_on_physical_attack(chara, params)
   -- >>>>>>>> elona122/shade2/action.hsp:1295 		if critical : skillExp rsCritical,cc,60/expModif ..
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
            Skill.gain_skill_exp(chara, "elona.two_hand", 20 / exp_modifier, 0, 4)
         end
         if chara:calc("is_dual_wielding") then
            Skill.gain_skill_exp(chara, "elona.dual_wield", 20 / exp_modifier, 0, 4)
         end
      elseif attack_skill == "elona.throwing" then
         Skill.gain_skill_exp(chara, "elona.tactics", 10 / exp_modifier, 0, 4)
      else
         Skill.gain_skill_exp(chara, "elona.marksman", 25 / exp_modifier, 0, 4)
      end

      -- TODO mount

      local target = params.target
      if Chara.is_alive(target) then
         local exp = math.clamp(250 * base_damage / target:calc("max_hp") + 1, 3, 100) / exp_modifier
         Skill.gain_skill_exp(target, target:calc("armor_class"), exp, 0, 5)
         if target:calc("is_wielding_shield") then
            Skill.gain_skill_exp(target, "elona.shield", 40 / exp_modifier, 0, 4)
         end
      end
   end

   -- <<<<<<<< elona122/shade2/action.hsp:1312 		} ..
end
Event.register("elona.on_physical_attack_hit", "Gain skill experience", proc_on_physical_attack, 100000)

local function proc_weapon_enchantments(chara, params)
   local weapon = params.weapon
   if params.weapon then
      -- >>>>>>>> elona122/shade2/action.hsp:1395 *act_attackSub ..
      for _, enc in weapon:iter_enchantments() do
         enc:on_attack_hit(chara, params)
      end
      -- <<<<<<<< elona122/shade2/action.hsp:1479 	return ..
   end

   -- >>>>>>>> elona122/shade2/calculation.hsp:325 		if ammoProc=encAmmoVopal : pierce=60 		:if sync( ..
   if params.ammo_enchantment then
      local ammo_enc_data = data["base.ammo_enchantment"]:ensure(params.ammo_enchantment)
      if ammo_enc_data.on_attack_hit then
         ammo_enc_data.on_attack_hit(chara, params)
      end
   end
   -- <<<<<<<< elona122/shade2/calculation.hsp:328 		if ammoProc=encAmmoMagic : damage/=10 ..
end
Event.register("elona.on_physical_attack_hit", "Proc weapon enchantments", proc_weapon_enchantments, 200000)

local function proc_damage_reflection(chara, params)
   local damage_reflection = params.target:calc("damage_reflection")
   if damage_reflection > 0 and not params.is_ranged then
      chara:damage_hp(params.damage * damage_reflection / 100 + 1, params.target, { element = "elona.cut", element_power = 100 })
   end
end
Event.register("elona.on_physical_attack_hit", "Proc damage reflection", proc_damage_reflection, 300000)

local function proc_damage_reaction(chara, params)
   -- >>>>>>>> elona122/shade2/action.hsp:1323         if cBarrier(tc)!0{ ..
   local damage_reaction = params.target:calc("damage_reaction")
   if damage_reaction then
      local damage_reaction_data = data["base.damage_reaction"]:ensure(damage_reaction.id)
      local power = damage_reaction.power
      if damage_reaction_data.on_damage then
         damage_reaction_data.on_damage(chara, power, params)
      end
   end
   -- <<<<<<<< elona122/shade2/action.hsp:1352         } ..
end
Event.register("elona.on_physical_attack_hit", "Proc damage reaction", proc_damage_reaction, 400000)
