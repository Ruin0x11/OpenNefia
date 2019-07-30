local Chara = require("api.Chara")
local Combat = require("mod.elona.api.Combat")
local Event = require("api.Event")
local Feat = require("api.Feat")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")

local ElonaAction = {}

local function shield_bash(chara, target)
   local shield = chara:skill_level("elona.shield")
   local do_bash = math.clamp(math.sqrt(shield) - 3, 1, 5) + ((chara:calc("has_power_bash") and 5) or 0)
   if Rand.percent_chance(do_bash) then
      Gui.mes_visible("Shield bash by " .. chara.uid)
      target:damage_hp(Rand.rnd(shield) + 1, chara)
      target:apply_effect("elona.dimming", 50 + math.floor(math.sqrt(shield)) * 15)
      target:add_effect_turns("elona.paralysis", Rand.rnd(3))
   end
end

function ElonaAction.get_melee_weapons(chara)
   local pred = function(entry) return entry.equipped:calc("is_weapon") end
   return chara:iter_body_parts():filter(pred):extract("equipped")
end

function ElonaAction.melee_attack(chara, target)
   if chara:calc("is_wielding_shield") then
      shield_bash(chara, target)
   end

   local attack_number = 0

   for _, weapon in ElonaAction.get_melee_weapons(chara) do
      local skill = weapon:calc("skill")
      attack_number = attack_number + 1
      ElonaAction.physical_attack(chara, weapon, target, skill, 0, attack_number)
   end

   if attack_number == 0 then
      ElonaAction.physical_attack(chara, nil, target, "elona.martial_arts", 0, attack_number)
   end
end

local function calc_exp_modifier(target)
   local map = target:current_map()

   return 1 + ((target:calc("is_hung_on_sand_bag") and 15) or 0)
      + ((target:calc("splits") and 1) or 0)
      + ((target:calc("splits2") and 1) or 0)
      + (map:calc("exp_modifier") or 0)
end

function ElonaAction.proc_weapon_enchantments(chara, weapon, target)
end

local function show_miss_text(chara, target, extra_attacks)
   if not Map.is_in_fov(chara.x, chara.y) then
      return
   end
   if extra_attacks > 0 then
      Gui.mes("Furthermore, ")
   end
   if target:is_ally() then
      Gui.mes(target.uid .. " skillfully evades " .. chara.uid .. ". ")
   else
      Gui.mes(chara.uid .. " misses " .. target.uid .. ". ")
   end
end

local function show_evade_text(chara, target, extra_attacks)
   if not Map.is_in_fov(chara.x, chara.y) then
      return
   end
   if extra_attacks > 0 then
      Gui.mes("Furthermore, ")
   end
   if target:is_ally() then
      Gui.mes(target.uid .. " skillfully evades " .. chara.uid .. ". ")
   else
      Gui.mes(target.uid .. " skillfully evades " .. chara.uid .. ". ")
   end
end

local function do_physical_attack(chara, weapon, target, attack_skill, extra_attacks, attack_number, is_ranged)
   if not Chara.is_alive(chara) or not Chara.is_alive(target) then
      return
   end

   if chara:has_effect("elona.fear") then
      Gui.mes(chara.uid .. " is frightened")
      return
   end

   -- mef

   if is_ranged then
      -- animation
   end

   attack_skill = attack_skill or "elona.martial_arts"

   local hit = Combat.calc_attack_hit(chara, weapon, target, attack_skill, attack_number, is_ranged)
   local did_hit = hit == "hit" or hit == "critical"
   local is_critical = hit == "critical"

   if did_hit then
      if chara:is_player() then
         if is_critical then
            Gui.mes("Critical!", "Red")
            Gui.play_sound("base.atk2")
         else
            Gui.play_sound("base.atk1")
         end
      end

      local raw_damage = Combat.calc_attack_damage(chara, weapon, target, attack_skill, is_ranged, is_critical)
      local damage = raw_damage.damage
      local play_animation = chara:is_player()
      if play_animation then
         local damage_percent = damage * 100 / target:calc("max_hp")
         -- animation
      end

      local element, element_power
      if weapon then
         Gui.mes(chara.uid .. " wields proudly the " .. weapon:build_name() .. ". ")
      else
         element = chara:calc("unarmed_element")
         element_power = chara:calc("unarmed_element_power")
         if element and not element_power then
            element_power = 0
         end
      end

      local tense = "enemy"
      if not target:is_ally() then
         tense = "ally"
      end

      local killed, base_damage, actual_damage = target:damage_hp(damage, chara, {element=element,element_power=element_power,extra_attacks=extra_attacks,weapon=weapon,message_tense=tense})

      chara:emit("elona.on_physical_attack_hit", {weapon=weapon,target=target,hit=hit,damage=damage,base_damage=base_damage,actual_damage=actual_damage,is_ranged=is_ranged,attack_skill=attack_skill,killed=killed})
   else
      local play_sound = chara:is_player()
      if play_sound then
         Gui.play_sound("base.miss")
      end
      chara:emit("elona.on_physical_attack_miss", {weapon=weapon,target=target,hit=hit,is_ranged=is_ranged,attack_skill=attack_skill})
   end

   if hit == "miss" then
      show_miss_text(chara, target, extra_attacks)
   elseif hit == "evade" then
      show_evade_text(chara, target, extra_attacks)
   end

   -- interrupt activity
   -- living weapon

   chara:emit("elona.after_physical_attack", {weapon=weapon,target=target,hit=hit,is_ranged=is_ranged,attack_skill=attack_skill})
end

function ElonaAction.physical_attack(chara, weapon, target, attack_skill, extra_attacks, attack_number, is_ranged)
   local attacks = extra_attacks
   local going

   repeat
      do_physical_attack(chara, weapon, target, attack_skill, extra_attacks, attack_number, is_ranged)
      going = false
      if attacks == 0 then
         if is_ranged then
            if Rand.percent_chance(chara:calc("extra_shot") or 0) then
               attacks = attacks + 1
               going = true
               -- TODO: remove ammo proc
            end
         else
            if Rand.percent_chance(chara:calc("extra_attack") or 0) then
               attacks = attacks + 1
               going = true
            end
         end
      end
   until not going
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

-- proc_damage_events_flag
-- 1:
--   - Print element damage 0 if chara is not killed
--   - do not trigger splitting behavior
-- 2:
--   - print "is scratched", "is slightly wounded", etc.
--   - print element text 1 if target is not party
--   - print transformed into meat/destroyed/minced if target is not party

function ElonaAction.prompt_really_attack(target)
   Gui.mes("Target: " .. target.uid .. ".")
   Gui.mes("Really attack?")

   return Input.yes_no()
end

function ElonaAction.bash(chara, x, y)
   for _, item in Item.at(x, y) do
      local result = item:emit("elona.on_bash", {chara=chara}, nil)
      if result then return true end
   end

   local target = Chara.at(x, y)
   if target then
      if not target:has_effect("elona.sleep") then
         if chara:is_player() and chara:reaction_towards(target) >= 0 then
            if not ElonaAction.prompt_really_attack(target) then
               return false
            end
         end
         if target:has_effect("elona.choked") then
            Gui.play_sound("base.bash1")
            Gui.mes(chara.uid .. " rams " .. target.uid .. " from choking.")
            local killed = target:damage_hp(chara:skill_level("elona.stat_strength") * 5, chara)
            if not killed then
               Gui.mes(target.uid .. " spits mochi.")
               target:remove_effect("elona.choked")
               -- TODO modify impress
            end
         else
            Gui.play_sound("base.bash1")
            Gui.mes(chara.uid .. " bashes up " .. target.uid .. ".")
            chara:act_hostile_towards(target)
         end
      else
         Gui.play_sound("base.bash1")
         Gui.mes(chara.uid .. " bashes up " .. target.uid .. " for sleep.")
         -- TODO modify karma
         -- TODO emotion icon
      end
      target:remove_effect("elona.sleep")
      return true
   end

   for _, feat in Feat.at(x, y) do
      local result = feat:emit("elona.on_bash", {chara=chara})
      if result then return true end
   end

   Gui.mes(chara.uid .. " bashes air.")
   return true
end

function ElonaAction.eat(chara, item)
   if chara:is_player() then
      if item.chara_using and item.chara_using.uid ~= chara.uid then
         Gui.mes("someone else is using")
         return false
      end
   elseif item.chara_using then
      item.chara_using:finish_activity()
      assert(item.chara_using == nil)
      Gui.mes_visible(chara.uid .. "snatches food.")
   end

   chara:start_activity("elona.eating", {food=item})

   return true
end

return ElonaAction
