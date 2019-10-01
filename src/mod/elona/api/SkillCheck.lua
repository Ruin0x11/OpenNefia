local SkillCheck = {}

function SkillCheck.try_to_reveal(chara)
   local skill = chara:skill_level("elona.detection") * 15 + 20 + chara:skill_level("elona.stat_perception")
   local dungeon = chara:current_map():calc("dungeon_level") * 8 + 60
   return Rand.rnd(skill) > Rand.rnd(dungeon)
end

return SkillCheck
