local InstancedEnchantment = require("api.item.InstancedEnchantment")
local Calc = require("mod.elona.api.Calc")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Log = require("api.Log")
local CharaMake = require("api.CharaMake")

local ItemMaterial = {}

-- These are global generation tables for materials. The material chosen depends
-- on the quality of the item/material and the level of the item/character
-- wielding it. The first dimension is chosen at random using a hardcoded
-- formula. The second dimension is indexed by quality from worst to best.
--
-- To make this moddable we'd have to change the formula since it assumes a
-- fixed 5x4 array of possible materials to choose from.

-- >>>>>>>> shade2/item_data.hsp:1122 	mtListMetal(0,0)	=mtBronze	,mtLead		,mtMica		,mtC ..
ItemMaterial.MATERIALS_METAL = {
    {"elona.bronze",    "elona.lead",      "elona.mica",     "elona.coral"},
    {"elona.iron",      "elona.silver",    "elona.glass",    "elona.obsidian"},
    {"elona.steel",     "elona.platinum",  "elona.pearl",    "elona.mithril"},
    {"elona.chrome",    "elona.crystal",   "elona.emerald",  "elona.adamantium"},
    {"elona.titanium",  "elona.diamond",   "elona.rubynus",  "elona.ether"}
}
-- <<<<<<<< shade2/item_data.hsp:1127  ..

-- >>>>>>>> shade2/item_data.hsp:1128 	mtListLeather(0,0)	=mtCloth	,mtSilk		,mtPaper	,mt ..
ItemMaterial.MATERIALS_SOFT = {
   {"elona.cloth",       "elona.silk",           "elona.paper",         "elona.bone"},
   {"elona.leather",     "elona.scale",          "elona.glass",         "elona.obsidian"},
   {"elona.chain",       "elona.platinum",       "elona.pearl",         "elona.mithril"},
   {"elona.zylon",       "elona.gold",           "elona.spirit_cloth",  "elona.dragon_scale"},
   {"elona.dawn_cloth",  "elona.griffon_scale",  "elona.rubynus",       "elona.ether"}
}
-- <<<<<<<< shade2/item_data.hsp:1133 	return ..

function ItemMaterial.choose_random_material(item, base_material, base_level, base_quality, chara_level)
   -- >>>>>>>> shade2/item_data.hsp:1143 *choose_material ...
   base_level = base_level or (item and item:calc("level")) or 0
   base_quality = base_quality or (item and item:calc("quality")) or 0
   local is_chara_make = chara_level ~= nil

   local level

   if is_chara_make then
      level = math.floor(chara_level / 15) + 1
   else
      level = math.floor(Rand.rnd(base_level+1) / 10 + 1)
   end
   -- <<<<<<<< shade2/item_data.hsp:1146  ..

   return ItemMaterial.choose_random_material_2(item, level, base_quality, base_material, chara_level)
end

function ItemMaterial.choose_random_material_2(item, level, base_quality, material, chara_level)
   level = math.floor(level)
   base_quality = math.floor(base_quality)

   if material == nil then
      material = data["base.item"]:ensure(item._id).material
   end
   if material == nil then
      material = "elona.sand"
   end

   base_quality = base_quality or (item and item:calc("quality")) or 0

   -- >>>>>>>> shade2/item_data.hsp:1147 	p=rnd(100) ...
   local i = Rand.rnd(100)
   local idx
   if i < 5 then
      idx = 4
   elseif i < 25 then
      idx = 3
   elseif i < 55 then
      idx = 2
   else
      idx = 1
   end

   if CharaMake.is_active() then
      level = 0
      idx = 1
   end

   level = math.clamp(Rand.rnd(level+1) + base_quality, 0, 5-1)

   if item:has_category("elona.furniture") then
      if Rand.one_in(2) then
         material = "elona.metal"
      else
         material = "elona.soft"
      end
   end

   if material == "elona.metal" then
      if not Rand.one_in(10) then
         material = ItemMaterial.MATERIALS_METAL[level][idx]
      else
         material = ItemMaterial.MATERIALS_SOFT[level][idx]
      end
   elseif material == "elona.soft" then
      if not Rand.one_in(10) then
         material = ItemMaterial.MATERIALS_SOFT[level][idx]
      else
         material = ItemMaterial.MATERIALS_METAL[level][idx]
      end
   end

   if Rand.one_in(25) then
      material = "elona.fresh"
   end

   assert(material and material ~= "elona.metal" and material ~= "elona.soft")

   return material
   -- <<<<<<<< shade2/item_data.hsp:1170 	return ...
end

function ItemMaterial.apply_material_enchantments(item, material)
   material = material or item:calc("material")
   if material == nil then
      return
   end

   local remove = {}
   for i, enc in ipairs(item.enchantments) do
      if enc.source == "material" then
         remove[#remove+1] = i
      end
   end
   table.remove_indices(item.enchantments, remove)

   local material_data = data["elona.item_material"]:ensure(material)
   for _, fixed_enc in ipairs(material_data.enchantments or {}) do
      local enc = InstancedEnchantment:new(
         fixed_enc._id,
         fixed_enc.power,
         table.deepcopy(fixed_enc.params or {}),
         "material"
      )
      item:add_enchantment(enc)
   end
end

function ItemMaterial.change_item_material(item, new_material)
   -- >>>>>>>> shade2/item_data.hsp:1175 	iCol(ci)=0 ..
   local cur_material = data["elona.item_material"]:ensure(item.material)
   local proto = item.proto
   item.weight = proto.weight or 0
   item.hit_bonus = proto.hit_bonus or 0
   item.damage_bonus = proto.damage_bonus or 0
   item.dv = proto.dv or 0
   item.pv = proto.pv or 0
   item.dice_y = proto.dice_y or 0
   item.color = proto.color or nil
   item.value = math.floor(item.value * 100 / cur_material.value)

   new_material = new_material or ItemMaterial.choose_random_material(item)

   ItemMaterial.apply_item_material(item, new_material)
   -- <<<<<<<< shade2/item_data.hsp:1187 	gosub *apply_material ..
end

function ItemMaterial.apply_item_material(item, material)
   -- >>>>>>>> shade2/item_data.hsp:1194  ..
   if item:has_category("elona.furniture") then
      if data["elona.item_material"]:ensure(material).no_furniture then
         material = "elona.wood"
      end
   end

   item.material = material

   local mat_data = data["elona.item_material"]:ensure(material)
   item.weight = math.floor(item.weight * mat_data.weight / 100)
   if item:has_category("elona.furniture") then
      item.value = item.value + mat_data.value * 2
   else
      item.value = math.floor(item.value * mat_data.value / 100)
   end

   item.color = item.color or mat_data.color

   local coeff = 120
   if item.quality == Enum.Quality.Bad then
      coeff = 150
   elseif item.quality == Enum.Quality.Normal then
      coeff = 100
   elseif item.quality >= Enum.Quality.Good then
      coeff = 80
   end

   if item.hit_bonus > 0 then
      item.hit_bonus = math.floor(mat_data.hit_bonus * item.hit_bonus * 9 / (coeff - Rand.rnd(30)))
   end
   if item.damage_bonus > 0 then
      item.damage_bonus = math.floor(mat_data.damage_bonus * item.damage_bonus * 5 / (coeff - Rand.rnd(30)))
   end
   if item.dv > 0 then
      item.dv = math.floor(mat_data.dv * item.dv * 7 / (coeff - Rand.rnd(30)))
   end
   if item.pv > 0 then
      item.pv = math.floor(mat_data.pv * item.pv * 9 / (coeff - Rand.rnd(30)))
   end
   if item.dice_y > 0 then
      item.dice_y = math.floor(mat_data.dice_y * item.dice_y / (coeff + Rand.rnd(25)))
   end

   ItemMaterial.apply_material_enchantments(item, material)
   -- <<<<<<<< shade2/item_data.hsp:1224 	return ..

   -- >>>>>>>> shade2/item_data.hsp:1189 	gosub *item_value ..
   item.value = ItemMaterial.recalc_quality(item)

   item:refresh()

   local owner = item:get_owning_chara()
   if owner then
      owner:refresh()
   end
   -- <<<<<<<< shade2/item_data.hsp:1191 	return ..
end

function ItemMaterial.recalc_quality(item)
   if item:has_category("elona.furniture") and (item.params.furniture_quality or 0) > 0 then
      return item.value * (80 + item.params.furniture_quality * 20) / 100
   end

   return item.value
end

return ItemMaterial
