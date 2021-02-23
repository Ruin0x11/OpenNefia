local Gui = require("api.Gui")
local Const = require("api.Const")
local Event = require("api.Event")
local Rand = require("api.Rand")
local Pos = require("api.Pos")

local Combat = {}

-- equipment type
-- & 2: two handed
-- & 4: dual wield

local function calc_accuracy_default(chara, weapon, attack_skill, ammo, params)
   local accuracy

   if weapon then
      accuracy = chara:skill_level("elona.stat_dexterity") / 4
         + chara:skill_level(weapon:calc("skill") or "elona.martial_arts") / 3
         + chara:skill_level(attack_skill)
         + 50
         + chara:calc("hit_bonus")
         + weapon:calc("hit_bonus")

      if ammo then
         accuracy = accuracy + ammo:calc("hit_bonus")
      end
   else
      accuracy = chara:skill_level("elona.stat_dexterity") / 5
         + chara:skill_level("elona.stat_strength") / 2
         + chara:skill_level(attack_skill)
         + 50

      if chara:calc("is_wielding_shield") then
         accuracy = accuracy * 100 / 130
      end

      accuracy = accuracy
         + chara:skill_level("elona.stat_dexterity") / 5
         + chara:skill_level("elona.stat_strength") / 10
         + chara:calc("hit_bonus")
   end

   return accuracy
end

local function mod_accuracy_for_equip_type(accuracy, chara, weapon, params)
   if weapon == nil then
      return accuracy
   end

   if params.is_ranged then
      if params.consider_distance and params.target then
         local dist = Pos.dist(chara.x, chara.y, params.target.x, params.target.y)
         local effective_range = weapon:calc_effective_range(dist)
         accuracy = accuracy * effective_range / 100
      end
   else
      if chara:calc("is_wielding_two_handed") then
         accuracy = accuracy + 25
         if weapon:calc("weight") >= Const.WEAPON_WEIGHT_HEAVY then
            accuracy = accuracy + chara:skill_level("elona.two_hand")
         end
      elseif chara:calc("is_dual_wielding") then
         if params.attack_count == 1 then
            if weapon:calc("weight") >= Const.WEAPON_WEIGHT_HEAVY then
               accuracy = accuracy - (weapon:calc("weight") - Const.WEAPON_WEIGHT_HEAVY + 400) / (10 + chara:skill_level("elona.dual_wield") / 5)
            end
         elseif weapon:calc("weight") > Const.WEAPON_WEIGHT_LIGHT then
            accuracy = accuracy - (weapon:calc("weight") - Const.WEAPON_WEIGHT_LIGHT + 100) / (10 + chara:skill_level("elona.dual_wield") / 5)
         end
      end
   end

   return accuracy
end

local function mod_accuracy_for_mount(accuracy, chara, weapon, is_ranged)
   -- TODO riding
   if not chara:get_mount() then
      return false
   end

   if chara:is_player() then
      accuracy = accuracy * 100 / math.clamp(150 - chara:skill_level("elona.riding") / 2, 115, 150)
      if weapon and not is_ranged and weapon:calc("weight") >= 4000 then
         accuracy = accuracy - (weapon:calc("weight") - 4000 + 400) / (10 + chara:skill_level("elona.riding") / 5)
      end
   end
   if chara:is_mount() then
      accuracy =
         accuracy * 100 / math.clamp(150 - chara:skill_level("elona.stat_strength") / 2, 115, 150);
      if weapon and not is_ranged and weapon:calc("weight") >= 4000 then
         accuracy = accuracy - (weapon:calc("weight") - 4000 + 400) / (10 + chara:skill_level("elona.stat_strength") / 10);
      end
   end

   return accuracy
end

local function mod_accuracy_for_attack_count(accuracy, chara, attack_count)
   if attack_count <= 1 then
      return accuracy
   end

   local hits = 100 - (attack_count - 1) * (10000 / (100 * chara:skill_level("elona.dual_wield") * 10))
   if accuracy > 0 then
      accuracy = accuracy * hits / 100
   end
   return accuracy
end

local hook_calc_accuracy = Event.define_hook("calc_accuracy",
                                             "Calculates the accuracy of a physical attack.",
                                             100.0,
                                             nil,
                                             function(_, params, result)
                                                return calc_accuracy_default(params.chara,
                                                                             params.weapon,
                                                                             params.attack_skill,
                                                                             params.ammo,
                                                                             params)
end)

Event.register("elona.hook_calc_accuracy",
               "Mod accuracy for equip type",
               function(_, params, result)
                  return mod_accuracy_for_equip_type(result, params.chara, params.weapon, params)
end)

Event.register("elona.hook_calc_accuracy",
               "Mod accuracy for attack_count",
               function(_, params, result)
                  return mod_accuracy_for_attack_count(result, params.chara, params.attack_count)
end)

function Combat.calc_accuracy(chara, weapon, target, attack_skill, attack_count, is_ranged, consider_distance)
   return hook_calc_accuracy({
         chara = chara,
         weapon = weapon,
         target = target,
         attack_skill = attack_skill,

         attack_count = attack_count or 1,
         is_ranged = is_ranged or false,
         consider_distance = consider_distance or false,
   })
end


local function calc_evasion_default(chara)
   return chara:skill_level("elona.stat_perception") / 3 + chara:skill_level("elona.evasion") + chara:calc("dv") + 25
end

local hook_calc_evasion = Event.define_hook("calc_evasion",
                                            "Calculates evasion.",
                                            0.0,
                                            nil,
                                            function(_, params, result)
                                               return calc_evasion_default(params.target)
end)

function Combat.calc_evasion(target, attacker, weapon, attack_skill, attack_count, is_ranged)
   return hook_calc_evasion({
         target = target,
         attacker = attacker,
         weapon = weapon,
         attack_skill = attack_skill,

         attack_count = attack_count or 1,
         is_ranged = is_ranged or false,
   })
end

local function mod_attack_hit_for_status_ailments(result, chara, target, is_ranged)
   -- >>>>>>>> shade2/calculation.hsp:216 	if cDim(tc)!0{ ...
   if chara:has_effect("elona.dimming") then
      if Rand.one_in(4) then
         result.result = "critical"
         return result, "blocked"
      end
      result.evasion = result.evasion / 2
   end
   if chara:has_effect("elona.blindness") then
      result.to_hit = result.to_hit / 2
   end
   if target:has_effect("elona.blindness") then
      result.evasion = result.evasion / 2
   end
   if target:has_effect("elona.sleep") then
      result.result = "hit"
      return result, "blocked"
   end
   if chara:has_effect("elona.confusion") or chara:has_effect("elona.dimming") then
      if is_ranged then
         result.to_hit = result.to_hit / 5
      else
         result.to_hit = result.to_hit / 3 * 2
      end
   end

   return result
   -- <<<<<<<< shade2/calculation.hsp:225 	if (cConfuse(cc)!0)or(cDim(cc)!0) : if AttackRang ..
end

local function mod_attack_hit_for_greater_evasion(result, target)
   -- >>>>>>>> shade2/calculation.hsp:227 	if sEvadePlus(tc)!0 : if toHit<sEvadePlus(tc)*10{ ...
   local greater_evasion = target:skill_level("elona.greater_evasion")
   if greater_evasion <= 0 then
      return result
   end

   if result.to_hit > 0 and result.to_hit < greater_evasion * 10 then
      local evade_ref = result.evasion * 100 / math.max(result.to_hit, 1)
      local value = Rand.rnd(greater_evasion + 250)
      if evade_ref > 300 then
         if value > 100 then
            result.result = "evade"
            return result, "blocked"
         end
      elseif evade_ref > 200 then
         if value > 150 then
            result.result = "evade"
            return result, "blocked"
         end
      elseif evade_ref > 150 then
         if value > 200 then
            result.result = "evade"
            return result, "blocked"
         end
      end
   end

   return result
   -- <<<<<<<< shade2/calculation.hsp:232 		} ..
end

local function mod_attack_hit_for_criticals(result, chara)
   if Rand.rnd(5000) < chara:skill_level("elona.stat_perception") + 50 then
      result.result = "critical"
      return result, "blocked"
   end

   if chara:calc("critical_rate") > Rand.rnd(200) then
      result.result = "critical"
      return result, "blocked"
   end

   if Rand.one_in(20) then
      result.result = "hit"
      return result, "blocked"
   end

   if Rand.one_in(20) then
      result.result = "miss"
      return result, "blocked"
   end

   return result
end

local hook_calc_attack_hit = Event.define_hook("calc_attack_hit",
                                               "Calculates if an attack hits or misses.",
                                               { result = "hit", to_hit = 100, evasion = 0 },
                                               nil)

Event.register("elona.hook_calc_attack_hit",
               "Mod attack hit for status ailments",
               function(_, params, result)
                  return mod_attack_hit_for_status_ailments(result, params.chara, params.target, params.is_ranged)
end)

Event.register("elona.hook_calc_attack_hit",
               "Mod attack hit for greater evasion",
               function(_, params, result)
                  return mod_attack_hit_for_greater_evasion(result, params.target)
end)

Event.register("elona.hook_calc_attack_hit",
               "Mod attack hit for criticals",
               function(_, params, result)
                  return mod_attack_hit_for_criticals(result, params.chara)
end)

function Combat.calc_attack_hit(chara, weapon, target, attack_skill, attack_count, is_ranged, ammo)
   local to_hit = Combat.calc_accuracy(chara, weapon, target, attack_skill, attack_count, is_ranged, true, ammo)
   local evasion = Combat.calc_evasion(target, chara, weapon, attack_skill, attack_count, is_ranged)

   local result = hook_calc_attack_hit({
         chara = chara,
         weapon = weapon,
         target = target,
         attack_skill = attack_skill,

         attack_count = attack_count or 1,
         is_ranged = is_ranged or false,
         ammo = ammo
                                       },
      { result = nil, to_hit = to_hit, evasion = evasion })

   if result.result then
      return result.result
   end

   if result.to_hit < 1 then
      return "miss"
   elseif result.evasion < 1 then
      return "hit"
   elseif Rand.rnd(result.to_hit) > Rand.rnd(result.evasion * 3 / 2) then
      return "hit"
   end

   return "miss"
end

local function calc_damage_params_default(chara, weapon, target, attack_skill, ammo)
   -- >>>>>>>> shade2/calculation.hsp:256 		dmgFix	= cDmg(cc) + iDmg(cw) +iLevel(cw)+(iStatu ..
   local dmgfix = chara:calc("damage_bonus") + weapon:calc("damage_bonus") + weapon:calc("bonus")
   if weapon:is_blessed() then
      dmgfix = dmgfix + 1
   end
   local dice_x = weapon:calc("dice_x")
   local dice_y = weapon:calc("dice_y")

   local multiplier
   if ammo then
      dmgfix = dmgfix + ammo:calc("damage_bonus") + ammo:calc("dice_x") * ammo:calc("dice_y") / 2
      multiplier = 0.5
         + (chara:skill_level("elona.stat_perception")
               + chara:skill_level(weapon:calc("skill") or "elona.throwing") / 5
               + chara:skill_level(attack_skill) / 5
               + chara:skill_level("elona.marksman") * 3 / 2)
         / 40
   else
      multiplier = 0.6
         + (chara:skill_level("elona.stat_strength")
               + chara:skill_level(weapon:calc("skill") or "elona.throwing") / 5
               + chara:skill_level(attack_skill) / 5
               + chara:skill_level("elona.tactics") * 2)
         / 40
   end

   local pierce_rate = weapon:calc("pierce_rate")

   return {
      dmgfix = dmgfix,
      dice_x = dice_x,
      dice_y = dice_y,
      multiplier = multiplier,
      pierce_rate = pierce_rate
   }
   -- <<<<<<<< shade2/calculation.hsp:264 		} ..
end

local function calc_raw_damage_for_skills(result, chara, weapon, target, is_ranged)
   if is_ranged then
      if target then
         local dist = Pos.dist(chara.x, chara.y, target.x, target.y)
         local effective_range = weapon:calc_effective_range(dist)
         result.multiplier = result.multiplier * effective_range / 100
      end
   elseif chara:calc("is_wielding_two_handed") then
      if weapon:calc("weight") >= 4000 then
         result.multiplier = result.multiplier * 1.5
      else
         result.multiplier = result.multiplier * 1.2
      end
      result.multiplier = result.multiplier + 0.03 * chara:skill_level("elona.two_hand")
   end

   return result
end

local function calc_raw_damage_for_traits(result, chara)
   if chara:has_trait("elona.ether_rage") then
      result.dmgfix = result.dmgfix + 5 + chara:calc("level") * 2 / 3
   end

   return result
end

local hook_calc_raw_damage =
   Event.define_hook("calc_raw_damage",
                     "Calculates damage before adjustment.",
                     { multiplier = 0, dmgfix = 0, dice_x = 0, dice_y = 0, pierce = 0 },
                     nil,
                     function(_, params, result)
                        return calc_raw_damage_for_skills(result, params.chara, params.weapon, params.target, params.is_ranged)
   end)

Event.register(
   "elona.hook_calc_raw_damage",
   "Trait: elona.ether_rage",
   function(_, params, result)
      return calc_raw_damage_for_traits(result, params.chara)
end)

function Combat.calc_attack_raw_damage(chara, weapon, target, attack_skill, is_ranged, ammo)
   local skill = data["base.skill"][attack_skill]

   local damage_params
   if skill and skill.calc_damage_params then
      damage_params = skill:calc_damage_params(chara, weapon, target, is_ranged, ammo)
   else
      damage_params = calc_damage_params_default(chara, weapon, target, attack_skill, ammo)
   end

   return hook_calc_raw_damage({
         chara = chara,
         weapon = weapon,
         target = target,
         attack_skill = attack_skill,
         is_ranged = is_ranged,
         ammo = ammo
                               },
      damage_params)
end

local function armor_skill_level(chara)
   local armor_class = chara:calc("armor_class")
   if data["base.skill"][armor_class] then
      return chara:skill_level(armor_class)
   end
   return 0
end

local function armor_penalty(chara)
   local armor_class = chara:calc("armor_class")
   local skill = data["base.skill"][armor_class]
   local penalty = 0
   if skill and skill.calc_armor_penalty then
      penalty = skill:calc_armor_penalty(chara)
   end
   return penalty
end

local function calc_protection_default(result, target)
   -- shade2/calculation.hsp:280 	prot		= cPV(tc)  + sdata(cArmor(tc),tc) +sDEX(tc)/10  ...
   result.amount = target:calc("pv") + armor_skill_level(target) + target:skill_level("elona.stat_dexterity") / 10

   if result.amount > 0 then
      local prot2 = result.amount / 4
      result.dice_x = math.max(prot2 / 10 + 1, 1)
      result.dice_y = prot2 / result.dice_x + 2
   end

   return result
end

local hook_calc_protection =
   Event.define_hook("calc_protection",
                     "Calculate protection.",
                     { amount = 0, dice_x = 1, dice_y = 1, fix = 0 },
                     nil,
                     function(_, params, result)
                        return calc_protection_default(result, params.target)
   end)

function Combat.calc_protection(target, attacker, weapon, attack_skill, is_ranged)
   return hook_calc_protection({
         target = target,
         attacker = attacker,
         weapon = weapon,
         attack_skill = attack_skill,
         is_ranged = is_ranged
   })
end

function Combat.calc_attack_damage(chara, weapon, target, attack_skill, is_ranged, is_critical, ammo, ammo_enc)
   local damage_params = Combat.calc_attack_raw_damage(chara, weapon, target, attack_skill, is_ranged, ammo)
   local protection_params = Combat.calc_protection(target, chara, weapon, attack_skill, is_ranged)

   -- >>>>>>>> shade2/calculation.hsp:297 	if dmgFix<-100:dmgFix=-100 ..
   damage_params.multiplier = math.floor(damage_params.multiplier * 100)
   local damage = Rand.roll_dice(damage_params.dice_x, damage_params.dice_y, math.max(damage_params.dmgfix, -100))

   local skill = data["base.skill"][attack_skill]

   if is_critical then
      damage = Rand.dice_max(damage_params.dice_x, damage_params.dice_y, damage_params.dmgfix)

      if skill.calc_critical_damage then
         damage_params = skill:calc_critical_damage(damage_params, protection_params, chara, weapon, target, is_ranged)
      elseif ammo then
         damage_params.multiplier = damage_params.multiplier * math.clamp(ammo:calc("weight") / 100 + 100, 100, 150) / 100
      else
         damage_params.multiplier = damage_params.multiplier * math.clamp(weapon:calc("weight") / 200 + 100, 100, 150) / 100
      end
   end

   damage = damage * damage_params.multiplier / 100
   local original_damage = damage
   local pierced = false

   if protection_params.amount > 0 then
      damage = damage * 100 / (100 + protection_params.amount)
   end

   if is_ranged then
      if ammo_enc then
         local ammo_enc_data = data["base.ammo_enchantment"]:ensure(ammo_enc)
         if ammo_enc_data.on_calc_damage then
            local params = {
               chara = chara,
               weapon = weapon,
               target = target,
               attack_skill = attack_skill,
               original_damage = original_damage,

               damage = damage,
               pierced = pierced
            }

            local result = ammo_enc_data.on_calc_damage(ammo, params)
            if result then
               damage = result.damage or damage
               if result.pierced ~= nil then
                  pierced = result.pierced
               end
            end
         end
      end
   else
      if Rand.percent_chance(chara:calc("pierce_rate")) then
         damage_params.pierce_rate = 100
         pierced = true
         if chara:is_in_fov() then
            Gui.mes_c("damage.vorpal.melee", "Yellow")
         end
      end
   end

   local pierce_damage = damage * damage_params.pierce_rate / 100
   local normal_damage = damage - pierce_damage

   if protection_params.amount > 0 then
      normal_damage = normal_damage - Rand.roll_dice(protection_params.dice_x, protection_params.dice_y, protection_params.fix)
      normal_damage = math.max(normal_damage, 0)
   end

   damage = pierce_damage + normal_damage

   if target:has_trait("elona.god_earth") then
      damage = damage * 95 / 100
   end

   local damage_resistance = target:calc("damage_resistance")
   if damage_resistance ~= 0 then
      damage = damage * 100 / math.clamp(100 + damage_resistance, 25, 1000)
   end

   damage = math.max(math.floor(damage), 0)

   return {
      damage = damage,
      pierced = pierced,
      normal_damage = normal_damage,
      pierce_damage = pierce_damage,
      original_damage = original_damage
   }
   -- <<<<<<<< shade2/calculation.hsp:343 	return damage ..
end

return Combat
