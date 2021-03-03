local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Event = require("api.Event")

local Material = {}

local global_materials = nil

function Material.random_material_id(level, rarity, choices)
   level = level or 0
   rarity = rarity or 0

   if global_materials == nil then
      global_materials = table.set(data["elona.material_spot"]:ensure("elona.global").materials or {})
   end

   local all_mats = data["elona.material"]:iter():to_list()

   -- >>>>>>>> shade2/material.hsp:4 #defcfunc random_material int bottomLv,int bottomR ..
   for i=1,500 do
      local entry = Rand.choice(all_mats)
      if i > 1 and (i-1) % 10 == 0 then
         level = level - 1
         rarity = rarity - 1
      end
      if entry.level >= level and entry.rarity >= rarity then
         if not choices or choices[entry._id] or global_materials[entry._id] then
            if Rand.one_in(entry.rarity) then
               return entry._id
            end
         end
      end
   end

   return nil
   -- <<<<<<<< shade2/material.hsp:29 	return f	 ..
end

function Material.gain(chara, material_id, num)
   -- >>>>>>>> shade2/material.hsp:32 #deffunc matGetMain int id,int num,int txtType ..
   local material_proto = data["elona.material"]:ensure(material_id)
   local get_verb = "activity.material.get_verb.get"
   if material_proto.get_verb then
      get_verb = material_proto.get_verb
   end

   num = math.max(num, 1)
   chara.materials[material_id] = (chara.materials[material_id] or 0) + num

   Gui.play_sound("base.alert1")
   Gui.mes_c("activity.material.get", "Blue", get_verb, num, "material." .. material_id .. ".name")
   -- <<<<<<<< shade2/material.hsp:47 	return ..
end

function Material.lose(chara, material_id, num)
   -- >>>>>>>> shade2/material.hsp:49 #deffunc matDelMain int id,int num ..
   data["elona.material"]:ensure(material_id)

   local current = chara.materials[material_id] or 0
   if current <= 0 then
      return
   end

   num = math.clamp(num, 1, current)
   chara.materials[material_id] = math.max(current - num, 0)

   Gui.mes_c("activity.material.lose", "Blue", num, "material." .. material_id .. ".name")
   -- <<<<<<<< shade2/material.hsp:54 	return ..
end

local function clear_global_materials_cache(_, params)
   if params.hotloaded_types["elona.material_spot"] or params.hotloaded_types["elona.material"] then
      global_materials = nil
   end
end
Event.register("base.on_hotload_end", "Clear material to spot cache", clear_global_materials_cache)

return Material
