local Skill = require("mod.elona_sys.api.Skill")

function mkdood(chara, levels)
   local chara = Chara.create(chara or "prinny.prinny")

   levels = levels or 10
   for _= 1, levels do
      Skill.gain_level(chara)
      Skill.grow_primary_skills(chara)
   end
   return chara
end
