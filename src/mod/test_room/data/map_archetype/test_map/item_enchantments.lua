local utils = require("mod.test_room.data.map_archetype.utils")
local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local Item = require("api.Item")
local Rand = require("api.Rand")

local item_enchantments = {
   _id = "item_enchantments"
}

local function items_in_category(cat)
   local filter = function(i)
      if i.enchantments ~= nil then
         return false
      end
      for _, c in ipairs(i.categories or {}) do
         if cat == c then
            return true
         end
      end
      return false
   end
   return data["base.item"]:iter():filter(filter):extract("_id"):to_list()
end

local function make_material_enchantments(x, y, map)
   local filter = function(mat)
      return mat.on_refresh or mat.fixed_enchantments
   end
   local mats = data["elona.item_material"]:iter():filter(filter):extract("_id")

   local ix = x
   local iy = y
   for _, idx, mat in mats:enumerate() do
      ix = x + ((idx - 1) % (map:width() - x - 2))
      iy = y + math.floor((idx - 1) / (map:width() - x - 2))

      local item = assert(Item.create("elona.composite_helm", ix, iy, {}, map))
      ItemMaterial.change_item_material(item, mat)
   end

   return 2, iy + 2
end

local function make_enchantments(x, y, map)
   local ids = {}

   local filter = function(enc)
      -- can fail if item category does not qualify for skill invokation
      return enc._id ~= "elona.invoke_skill" and enc._id ~= "elona.ammo"
   end

   local ix = x
   local iy = y
   for _, idx, enc in data["base.enchantment"]:iter():filter(filter):enumerate() do
      ix = x + ((idx - 1) % (map:width() - x - 2))
      iy = y + math.floor((idx - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      local categories = { "elona.equip_body" }
      for _, cat in ipairs(categories) do
         if ids[cat] == nil then
            ids[cat] = items_in_category(cat)
         end
         local _id = Rand.choice(ids[cat])
         for i= -1, 1, 2 do
            local power = 150 * i
            local item = assert(Item.create(_id, ix, iy, {}, map))
            item:add_enchantment(enc._id, power, "randomized")
         end
      end
   end

   return 2, iy + 2
end

local function make_enchantment_skills(x, y, map)
   local ids = {}

   local ix = x
   local iy = y
   for _, idx, enc_skill in data["base.enchantment_skill"]:iter():enumerate() do
      ix = x + ((idx - 1) % (map:width() - x - 2))
      iy = y + math.floor((idx - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      local categories = enc_skill.categories or { "elona.equip_ranged" }
      for _, cat in ipairs(categories) do
         if ids[cat] == nil then
            ids[cat] = items_in_category(cat)
         end
         local _id = Rand.choice(ids[cat])
         for i= -1, 1, 2 do
            local power = 150 * i
            local item = assert(Item.create(_id, ix, iy, {}, map))
            item:add_enchantment("elona.invoke_skill", power, {enchantment_skill_id = enc_skill._id})
         end
      end
   end

   return 2, iy + 2
end

local function make_fixed_enchantments(x, y, map)
   local filter = function(i)
      return i.enchantments ~= nil
   end

   local ix = x
   local iy = y
   for _, idx, item in data["base.item"]:iter():filter(filter):enumerate() do
      ix = x + ((idx - 1) % (map:width() - x - 2))
      iy = y + math.floor((idx - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      assert(Item.create(item._id, ix, iy, {}, map))
   end

   return 2, iy + 2
end

local function make_resist_enchantments(x, y, map)
   local ids = {}

   local ix = x
   local iy = y
   for _, idx, elem in data["base.element"]:iter():filter(function(e) return e.can_resist end):enumerate() do
      ix = x + ((idx - 1) % (map:width() - x - 2))
      iy = y + math.floor((idx - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      local categories = { "elona.equip_body" }
      for _, cat in ipairs(categories) do
         if ids[cat] == nil then
            ids[cat] = items_in_category(cat)
         end
         local _id = Rand.choice(ids[cat])
         for i= -1, 1, 2 do
            local power = 150 * i
            local item = assert(Item.create(_id, ix, iy, {}, map))
            item:add_enchantment("elona.modify_resistance", power, { element_id = elem._id })
         end
      end
   end

   return 2, iy + 2
end

function item_enchantments.on_generate_map(area, floor)
   local map = utils.create_map(20, 30)
   utils.create_stairs(2, 2, area, map)

   local x = 2
   local y = 5

   utils.create_sandbag(4, 2, map)

   x, y = make_material_enchantments(x, y, map)
   x, y = make_enchantments(x, y, map)
   x, y = make_enchantment_skills(x, y, map)
   x, y = make_fixed_enchantments(x, y, map)
   x, y = make_resist_enchantments(x, y, map)

   Item.iter(map):each(function(i) Effect.identify_item(i, Enum.IdentifyState.Full) end)

   return map
end

return item_enchantments
