local Gui = require("api.Gui")
local Rand = require("api.Rand")

local Material = {}

function Material.random_material_id(level, rarity, choices)
   -- >>>>>>>> shade2/material.hsp:4 #defcfunc random_material int bottomLv,int bottomR ..
   for i=1,500 do
      local entry = Rand.choice(data["elona.material"])
      if i % 10 == 0 then
         level = level - 1
         rarity = rarity - 1
      end
      if entry.level >= level then
         if entry.rarity >= rarity then
            if not choices or choices[entry._id] then
               if Rand.one_in(entry.rarity) then
                  return entry
               end
            end
         end
      end
   end

   return nil
   -- <<<<<<<< shade2/material.hsp:29 	return f	 ..
end

function Material.obtain(chara, id, num, txt_type)
   -- >>>>>>>> shade2/material.hsp:32 #deffunc matGetMain int id,int num,int txtType ..
   num = math.max(num, 1)
   if chara.materials[id] then
      chara.materials[id] = chara.materials[id] + num
   else
      chara.materials[id] = num
   end
   Gui.play_sound("base.alert")
   Gui.mes("matgain", "Blue")
   -- <<<<<<<< shade2/material.hsp:47 	return ..
end

function Material.lose(chara, id, num)
   -- >>>>>>>> shade2/material.hsp:49 #deffunc matDelMain int id,int num ..
   num = math.max(num, 1)
   chara.materials[id] = math.max((chara.materials[id] or 0) - num, 0)
   Gui.mes("matlose", "Blue")
   -- <<<<<<<< shade2/material.hsp:54 	return ..
end

return Material
