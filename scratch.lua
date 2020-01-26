local Skill = require("mod.elona_sys.api.Skill")

function mkdood(chara, levels)
   local chara = Chara.create(chara or "prinny.prinny")

   levels = levels or 10
   for _= 1, levels do
      Skill.gain_level(chara)
      Skill.grow_primary_skills(chara)
      if _ > 100 then
         require("api.Debug").print_end()
      end
   end
   return chara
end

function posses()
   local p = Chara.player()
   local down = Map.current():iter_feats():filter(function(f) return f._id == "elona.stairs_up" end):nth(1)
   local up = Map.current():iter_feats():filter(function(f) return f._id == "elona.stairs_down" end):nth(1)
   return {
      player = {p.x, p.y},
      up = {up.x, up.y},
      down = {down.x, down.y},
   }
end
