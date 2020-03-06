local Calc = require("mod.elona.api.Calc")
local Rand = require("api.Rand")
local Enum = require("api.Enum")

local ItemMaterial = {}

local MATERIALS_METAL = {
    {"elona.bronze", "elona.lead", "elona.mica", "elona.coral"},
    {"elona.iron", "elona.silver", "elona.glass", "elona.obsidian"},
    {"elona.steel", "elona.platinum", "elona.pearl", "elona.mithril"},
    {"elona.chrome", "elona.crystal", "elona.emerald", "elona.adamantium"},
    {"elona.titanium", "elona.diamond", "elona.rubynus", "elona.ether"}
}

local MATERIALS_SOFT = {
   {"elona.cloth", "elona.silk", "elona.paper", "elona.bone"},
   {"elona.leather", "elona.scale", "elona.glass", "elona.obsidian"},
   {"elona.chain", "elona.platinum", "elona.pearl", "elona.mithril"},
   {"elona.zylon", "elona.gold", "elona.spirit", "elona.dragon"},
   {"elona.dusk", "elona.griffon", "elona.rubynus", "elona.ether"}
}

function ItemMaterial.get_starting_material(item, chara, chara_make)
   local level
   local material = item.material
   if chara then
      level = math.floor(chara:calc("level") / 15) + 1
   else
      level = Rand.rnd(item:calc("level") / 10) + 1
   end

   if item.id == "elona.item_material_kit" then
      level = Rand.rnd(level + 1)
      if Rand.one_in(3) then
         material = "elona.metal"
      else
         material = "elona.soft"
      end
   end

   local i = Rand.rnd(100)
   local idx
   if i < 5 then
      idx = 2
   elseif i < 25 then
      idx = 3
   elseif i < 55 then
      idx = 4
   else
      idx = 1
   end

   if chara_make then
      level = 0
      idx = 1
   end

   level = math.min(level, 5-1)
   level = math.clamp(Rand.rnd(level+1) + item:calc("quality"), 0, 5-1)

   if item:has_category("elona.furniture") then
      if Rand.one_in(2) then
         material = "elona.metal"
      else
         material = "elona.soft"
      end
   end

   if material == "elona.metal" then
      if not Rand.one_in(10) then
         material = MATERIALS_METAL[idx][level+1]
      else
         material = MATERIALS_SOFT[idx][level+1]
      end
   end
   if material == "elona.soft" then
      if not Rand.one_in(10) then
         material = MATERIALS_SOFT[idx][level+1]
      else
         material = MATERIALS_METAL[idx][level+1]
      end
   end

   if Rand.one_in(25) then
      material = "elona.fresh"
   end

   return material or item.material or "elona.sand"
end

local function apply_material_enchantments(item, material)
   -- TODO
end

local function remove_material_enchantments(item, material)
   -- TODO
end

function ItemMaterial.change_item_material(item, material, do_reset)
   if do_reset then
      local cur_material = data["elona.item_material"]:ensure(item.material)
      remove_material_enchantments(item)
      local proto = item.proto
      item.weight = proto.weight
      item.hit_bonus = proto.hit_bonus
      item.damage_bonus = proto.damage_bonus
      item.dv = proto.dv
      item.pv = proto.pv
      item.dice_y = proto.dice_y
      item.color = proto.color
      item.value = math.floor(item.value * 100 / cur_material.value)
   end

   if material == nil then
      material = ItemMaterial.get_starting_material(item)
   end

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
   elseif item.quality == Enum.Quality.Good then
      coeff = 100
   elseif item.quality >= Enum.Quality.Great then
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

   apply_material_enchantments(item, material)

   item.value = Calc.item_value(item)

   local owner = item:get_owning_chara()
   if owner then
      owner:refresh()
   end
end

return ItemMaterial