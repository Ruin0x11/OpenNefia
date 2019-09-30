local Rand = require("api.Rand")
local Map = require("api.Map")
local Gui = require("api.Gui")

local Skill = {}

function Skill.calc_initial_potential(skill, level, knows_skill)
   local p

   if skill.skill_type == "stat" then
      p = math.min(level * 20, 400)
   else
      p = level * 5
      if knows_skill then
         p = p + 50
      else
         p = p + 100
      end
   end

   return p
end

function Skill.calc_initial_decayed_potential(base_potential, chara_level)
   if chara_level <= 1 then
      return base_potential
   end

   return math.floor(math.exp(math.log(0.9) * chara_level) * base_potential)
end

function Skill.calc_initial_skill_level(skill, initial_level, original_level, chara_level, chara)
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

   level = math.clamp(level, 0, 2000)

   return {
      level = level,
      potential = potential
   }
end

function Skill.calc_related_stat_exp(exp, exp_divisor)
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

local function get_skill_buff(chara, skill)
   local buffs = chara:calc("growth_buffs") or {}
   local list = buffs["base.skill"] or {}
   return list[skill] or 0
end

function Skill.calc_chara_exp_from_skill_exp(required_exp, level, skill_exp, exp_divisor)
   return Rand.rnd(required_exp * skill_exp / 1000 / (level + exp_divisor) + 1) + Rand.rnd(2)
end

function Skill.modify_potential(potential, level_delta)
   if level_delta > 0 then
      for _=0,level_delta do
         potential = math.max(math.floor(potential * 0.9), 1)
      end
   elseif level_delta < 0 then
      for _=0,-level_delta do
         potential = math.min(math.floor(potential * 1.1) + 1, 400)
      end
   end
   return potential
end

function Skill.gain_skill_exp(chara, skill, base_exp, exp_divisor_stat, exp_divisor_level)
   exp_divisor_stat = exp_divisor_stat or 0
   exp_divisor_level = exp_divisor_level or 0

   local skill_data = data["base.skill"]:ensure(skill)

   if not chara:has_skill(skill) then return end
   if base_exp == 0 then return end

   if skill_data.related_stat then
      local exp = Skill.calc_related_stat_exp(base_exp, exp_divisor_stat)
      Skill.gain_skill_exp(chara, skill_data.related_stat, exp)
   end

   local level = chara:skill_level(skill)
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

   local is_show_house = false -- TODO
   if is_show_house then
      exp = exp / 5
   end

   if exp > 0 and skill_data.apply_exp_divisor and exp_divisor_level ~= 1000 then
      local lvl_exp = Skill.calc_chara_exp_from_skill_exp(chara:calc("required_experience"), chara:calc("level"), exp, exp_divisor_level)
      chara.experience = chara.experience + lvl_exp
      if chara:is_player() then
         chara.sleep_experience = chara.sleep_experience + lvl_exp
      end
   end

   local new_exp = exp + chara:skill_experience(skill)
   if new_exp >= 1000 then
      local level_delta = math.floor(new_exp / 1000)
      new_exp = new_exp % 1000
      level = level + level_delta
      potential = Skill.modify_potential(potential, level_delta)
      chara:set_base_skill(skill, level, potential, new_exp)
      if Map.is_in_fov(chara.x, chara.y) then
         local color
         if chara:is_ally() then
            Gui.play_sound("base.ding3")
            color = "Green"
         end
         Gui.mes(chara.uid .. " levels up " .. skill, color)
      end
      chara:refresh()
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
      potential = Skill.modify_potential(potential, -level_delta)
      chara:set_base_skill(skill, level, potential, new_exp)
      if Map.is_in_fov(chara.x, chara.y) and level_delta ~= 0 then
         Gui.mes(chara.uid .. " loses a level of " .. skill, "Red")
      end
      chara:refresh()
   end

   chara:set_base_skill(skill, level, potential, new_exp)
end

return Skill
