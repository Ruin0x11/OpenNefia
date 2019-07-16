local ICharaSkills = class.interface("ICharaSkills")

function ICharaSkills:init()
   self.skills = self.skills or {}
end

function ICharaSkills:skill_level(skill)
   return 10
end

function ICharaSkills:stat_level(stat)
   return 10
end

function ICharaSkills:spell_level(spell)
   return 10
end

return ICharaSkills
