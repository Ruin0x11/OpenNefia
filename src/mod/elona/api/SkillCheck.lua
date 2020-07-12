local Gui = require("api.Gui")
local Skill = require("mod.elona_sys.api.Skill")
local Rand = require("api.Rand")

local SkillCheck = {}

function SkillCheck.try_to_reveal(chara)
   local skill = chara:skill_level("elona.detection") * 15 + 20 + chara:skill_level("elona.stat_perception")
   local dungeon = chara:current_map():calc("dungeon_level") * 8 + 60
   return Rand.rnd(skill) > Rand.rnd(dungeon)
end

function SkillCheck.proc_control_magic(source, target, damage)
   if source:has_skill("elona.control_magic") and source:is_in_same_faction(target) then
      local level = source:skill_level("elona.control_magic")
      if level * 5 > Rand.rnd(damage+1) then
         damage = 0
      else
         damage = Rand.rnd(damage * 100 / (100 + level * 10) + 1)
      end

      if damage < 1 then
         return "success", damage
      end

      return "attempted", damage
   end

   return nil, damage
end

function SkillCheck.handle_control_magic(source, target, damage)
   local stat, damage = SkillCheck.proc_control_magic(source, target, damage)

   if stat == "success" then
      Gui.mes_visible("misc.spell_passes_through", target.x, target.y, target)
      Skill.gain_skill_exp(source, "elona.control_magic", 8, 4)
      return true, damage
   elseif stat == "attempted" then
      Skill.gain_skill_exp(source, "elona.control_magic", 30, 2)
      return false, damage
   else
      return false, damage
   end
end

function SkillCheck.is_floating(chara)
   return chara:calc("is_floating") and not chara:has_effect("elona.gravity")
end

return SkillCheck
