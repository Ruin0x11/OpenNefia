local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Event = require("api.Event")
local Feat = require("api.Feat")
local I18N = require("api.I18N")

local Material = {}

local global_materials = nil

function Material.random_material_id(level, rarity, choices)
   level = math.clamp(level or 0, 0, 25)
   rarity = math.clamp(rarity or 0, 0, 40)
   if choices then
      choices = table.set(choices)
   end

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

function Material.gain(chara, material_id, num, get_verb)
   -- >>>>>>>> shade2/material.hsp:32 #deffunc matGetMain int id,int num,int txtType ..
   data["elona.material"]:ensure(material_id)
   get_verb = get_verb or "activity.material.get_verb.get"

   num = math.max(num, 1)
   chara.materials[material_id] = (chara.materials[material_id] or 0) + num

   Gui.play_sound("base.alert1")

   local text = I18N.get("activity.material.get", get_verb, num, "material." .. material_id .. ".name")
   text = ("%s (%d)"):format(text, chara.materials[material_id])
   Gui.mes_c(text, "Blue")
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


local function calc_base_mat_spot_level(map, chara)
   local level = map:calc("level")

   if map:has_type("world_map") then
      level = math.floor(chara:calc("level") / 2) + Rand.rnd(10)
      if level > 30 then
         level = 30 + Rand.rnd(Rand.rnd(level-30)+1)
      end
   end

   return level
end

local function calc_base_mat_spot_type(map, chara)
   local mat_spot_id = map:calc("material_spot_type") or "elona.field"

   if map:has_type("world_map") then
      local tile = map:tile(chara.x, chara.y)
      if tile.field_type then
         local field_type = data["elona.field_type"]:ensure(tile.field_type)
         if field_type.material_spot_type then
            mat_spot_id = field_type.material_spot_type
         end
      end
   end

   return mat_spot_id
end

function Material.dig_random_site(chara, feat)
   -- >>>>>>>> shade2/proc.hsp:10 *randomSite ..
   local map = chara:current_map()

   if not Feat.is_alive(feat, map) then
      return true
   end

   local level = calc_base_mat_spot_level(map, chara)
   local site = calc_base_mat_spot_type(map, chara)

   if feat then
      local ty = feat:calc("material_spot_type")
      if ty then
         site = ty
      end
      local res = feat:emit("elona.on_feat_calc_materials", {chara=chara}, {level=level,material_spot_type=site})
      if res then
         level = res.level or level
         site = res.material_spot_type or site
      end
   end

   local site_data = data["elona.material_spot"]:ensure(site)
   local get_verb = site_data.get_verb or "activity.material.get_verb.find"

   if Rand.one_in(7) then
      local choices = site_data.materials or {}
      local id
      local amount = 1

      if site_data.on_search then
         id = site_data.on_search(chara, feat, level, choices)
      else
         id = Material.random_material_id(level, 1, choices)
      end

      if id then
         Material.gain(chara, id, amount, get_verb)
      end
   end

   if Rand.one_in(50 + chara:trait_level("elona.perm_material") * 20) then
      return true
   end

   return false
   -- <<<<<<<< shade2/proc.hsp:64 	return ..
end

return Material
