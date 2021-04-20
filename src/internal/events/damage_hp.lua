local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Event = require("api.Event")
local Enum = require("api.Enum")

local function after_chara_damaged(victim, params)
   local element = params.element
   if element and element.after_apply_damage then
      element.after_apply_damage(victim, params)
   end
end
Event.register("base.after_chara_damaged", "Apply element damage.", after_chara_damaged)

-- >>>>>>>> shade2/chara_func.hsp:1541 		if ele{ ...
local function apply_element_on_damage(victim, params)
   if params.element and params.element.on_damage then
      params.element.on_damage(victim, params)
   end
end
-- <<<<<<<< shade2/chara_func.hsp:1558 			} ..
Event.register("base.on_damage_chara", "Element on_damage effects", apply_element_on_damage)

-- >>>>>>>> shade2/chara_func.hsp:1541 		if ele{ ...
local function apply_element_on_kill(victim, params)
   if params.element and params.element.on_kill then
      params.element.on_damage(victim, params)
   end
end
-- <<<<<<<< shade2/chara_func.hsp:1558 			} ..
Event.register("base.on_chara_killed", "Element on_kill effects", apply_element_on_kill)

local function on_kill_chara(victim, params)
   -- >>>>>>>> shade2/chara_func.hsp:1689 			if dmgSource!pc:customTalk dmgSource,dbModeTxtK ..
   local attacker = params.attacker

   if attacker then
      if not attacker:is_player() then
         attacker:say("base.killed", { victim = victim, params = params })
      end
      local gained_exp = victim:emit("base.on_calc_kill_exp", params, 0)

      -- TODO chara:gain_experience() to allow global experience
      -- modifier
      attacker.experience = attacker.experience + gained_exp
      if attacker:is_player() then
         attacker.sleep_experience = attacker.sleep_experience + gained_exp
      end
      attacker:set_target(nil)
   end
   -- <<<<<<<< shade2/chara_func.hsp:1695 			} ..
end
Event.register("base.on_kill_chara", "Default kill handler.", on_kill_chara)

local function apply_hostile_action(victim, params)
   -- >>>>>>>> shade2/chara_func.hsp:1583 		if dmgSource>=0{ ..
   local attacker = params.attacker

   if attacker == nil or victim:is_player() then
      return
   end

   local apply_aggro = false
   if victim:relation_towards(attacker) <= Enum.Relation.Enemy then
      if victim:base_relation_towards(attacker) > Enum.Relation.Enemy then
         if (victim:get_aggro(attacker) <= 0 or Rand.one_in(4)) then
            apply_aggro = true
         end
      end
   else
      if victim:base_relation_towards(attacker) <= Enum.Relation.Enemy then
         if (victim:get_aggro(attacker) <= 0 or Rand.one_in(4)) then
            apply_aggro = true
         end
      end
   end

   if not attacker:is_player() and attacker:get_target() == victim and Rand.one_in(3) then
      apply_aggro = true
   end

   if apply_aggro then
      if not victim:is_player() then
         victim:set_target(attacker)
      end

      if victim.aggro <= 0 then
         victim:set_emotion_icon("elona.angry", 2)
         victim.aggro = 20
      else
         victim.aggro = victim.aggro + 2
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:1593 		} ..
end
Event.register("base.on_damage_chara", "Hostile action towards AI", apply_hostile_action)

local function magic_reaction(source, p)
   -- >>>>>>>> shade2/chara_func.hsp:1778 	if cMP(tc)<0{	 ..
   if source.mp < 0 and not p.no_magic_reaction then
      source:emit("base.on_magic_reaction", {})
      local Skill = require("mod.elona_sys.api.Skill")
      Skill.gain_skill_exp(source, "elona.magic_capacity", math.abs(source.mp) * 200 / (source:calc("max_mp") + 1))
      local damage = (source.mp * -1) * 400 / (100 + source:skill_level("elona.magic_capacity") * 10)
      if source:is_player() then
         if source:has_trait("elona.perm_capacity") then
            damage = damage / 2
         end
      else
         damage = damage / 5
         if damage < 10 then
            return
         end
      end
      Gui.mes("damage.magic_reaction_hurts", source)
      source:damage_hp(damage, "elona.magic_overcast")
   end
   -- <<<<<<<< shade2/chara_func.hsp:1789 	return true ..
end
Event.register("base.on_damage_chara_mp", "Magic reaction", magic_reaction)
