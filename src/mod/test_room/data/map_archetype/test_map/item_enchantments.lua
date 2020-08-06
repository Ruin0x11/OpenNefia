local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Enchantment = require("mod.elona.api.Enchantment")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local Item = require("api.Item")
local Area = require("api.Area")
local Rand = require("api.Rand")

local function create_map(width, height)
   width = width or 50
   height = height or 50
   local map = InstancedMap:new(width, height)
   map:clear("elona.cobble")
   map.is_indoor = true
   for _, x, y in Pos.iter_border(0, 0, width - 1, height - 1) do
      map:set_tile(x, y, "elona.wall_dirt_dark_top")
   end

   for _, x, y in map:iter_tiles() do
      map:memorize_tile(x, y)
   end

   return map
end

local function create_stairs(x, y, area, map)
   assert(Area.create_stairs_up(area, 1, x, y, {}, map))
end

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

   return 3, iy + 2
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

      local categories = enc.categories or { "elona.equip_body" }
      for _, cat in ipairs(categories) do
         if ids[cat] == nil then
            ids[cat] = items_in_category(cat)
         end
         local _id = Rand.choice(ids[cat])
         for i= -1, 1, 2 do
            local power = 150 * i
            local item = assert(Item.create(_id, ix, iy, {}, map))
            local e = assert(Enchantment.create(enc._id, power, item))
            item:add_enchantment(e)
         end
      end
   end

   return 3, iy + 2
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
            local e = assert(Enchantment.create("elona.invoke_skill", power, item))
            e.params.enchantment_skill_id = enc_skill._id
            item:add_enchantment(e)
         end
      end
   end

   return 3, iy + 2
end

local function make_ammo_enchantments(x, y, map)
   local ids = items_in_category("elona.equip_ammo")

   local ix = x
   local iy = y
   for _, idx, enc_skill in data["base.ammo_enchantment"]:iter():enumerate() do
      ix = x + ((idx - 1) % (map:width() - x - 2))
      iy = y + math.floor((idx - 1) / (map:width() - x - 2))
      if not map:can_access(ix, iy) then
         break
      end

      local _id = Rand.choice(ids)
      for i= -1, 1, 2 do
         local power = 150 * i
         local item = assert(Item.create(_id, ix, iy, {}, map))
         local e = assert(Enchantment.create("elona.ammo", power, item, { is_from_material = true }))
         e.params.enchantment_skill_id = enc_skill._id
         item:add_enchantment(e)
      end
   end

   return 3, iy + 2
end

local function make_fixed_enchantments(x, y, map)
   local ids = items_in_category("elona.equip_ammo")

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

   return 3, iy + 2
end

local function generate_map(area, floor)
   local map = create_map(20, 100)
   create_stairs(3, 3, area, map)

   local x = 3
   local y = 5

   local ids = {}

   x, y = make_material_enchantments(x, y, map)
   x, y = make_enchantments(x, y, map)
   x, y = make_enchantment_skills(x, y, map)
   x, y = make_ammo_enchantments(x, y, map)
   x, y = make_fixed_enchantments(x, y, map)

   Item.iter(map):each(function(i) Effect.identify_item(i, Enum.IdentifyState.Full) end)

   return map
end

return {
   item_enchantments = generate_map
}
