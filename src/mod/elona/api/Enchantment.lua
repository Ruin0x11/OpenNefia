local InstancedEnchantment = require("api.item.InstancedEnchantment")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local WeightedSampler = require("mod.tools.api.WeightedSampler")
local Enum = require("api.Enum")

local Enchantment = {}

function Enchantment.power_text(grade, no_brackets)
   grade = math.abs(grade)
   local grade_str = I18N.get("enchantment.level")
   local s = ""
   for i = 1, grade + 1 do
      if i > 4 then
         s = s .. "+"
         break
      end
      s = s .. grade_str
   end
   if not no_brackets then
      s = "[" .. s .. "]"
   end
   return s
end

Enchantment.MAX_RANDOM_EGO_ENCHANTMENTS = 5
Enchantment.MAX_EGO_ENCHANTMENTS = 10
Enchantment.MAX_ENCHANTMENT_LEVEL = 4

local function rand_data_id(ty)
   return Rand.choice(data[ty]:iter():extract("_id"))
end

--- @tparam integer level
--- @tparam IItem item
--- @treturn[opt] id:base_enchantment
function Enchantment.random_enc_id(item, level)
   -- >>>>>>>> shade2/item_data.hsp:463 	#module ...
   level = level or 0

   local filter = function(enc)
      if enc.level > level then
         return false
      end

      if level >= 0 and enc.level < 0 then
         return false
      end

      if enc.filter and not enc.filter(item) then
         return false
      end

      return true
   end

   local sampler = WeightedSampler:new()
   for _, enc in data["base.enchantment"]:iter():filter(filter) do
      local weight = enc.rarity
      sampler:add(enc._id, weight)
   end

   -- This may return nil.
   return sampler:sample()
   -- <<<<<<<< shade2/item_data.hsp:481 	return i ..
end

--- @hsp randomEncLv(level)
function Enchantment.random_enc_level(item, level)
   -- >>>>>>>> shade2/item_data.hsp:483 	#defcfunc randomEncLv int refLv ...
   level = math.clamp(level or 0, 0, Enchantment.MAX_ENCHANTMENT_LEVEL)
   return Rand.rnd(level + 1)
   -- <<<<<<<< shade2/item_data.hsp:486 	return encLv ..
end

--- @hsp randomEncP(level)
function Enchantment.random_enc_power(item, level)
   -- >>>>>>>> shade2/item_data.hsp:489 	#defcfunc randomEncP int refLv ...
   local has_god_luck = false
   local player = Chara.player()
   if player then
      has_god_luck = player:has_trait("elona.god_luck")
   end
   local power = Rand.rnd(Rand.rnd(500 + (has_god_luck and 50 or 0)) + 1) + 1
   if (level or 0) ~= 0 then
      power = power * level / 100
   end
   return power
   -- <<<<<<<< shade2/item_data.hsp:492 	return encP ..
end

function Enchantment.generate(item, ego_level, power_level, curse_power, source)
   local level = Enchantment.random_enc_level(item, ego_level)
   return Enchantment.generate_fixed_level(item, level, power_level, curse_power, source)
end

function Enchantment.generate_fixed_level(item, level, power_level, curse_power, source)
   local _id = Enchantment.random_enc_id(item, level)
   if _id then
      local power = Enchantment.random_enc_power(item, power_level)
      return InstancedEnchantment:new(_id, power, "randomized", curse_power or 0, source or "generated")
   end
   return nil
end

--- @hsp *item_egoMinor
function Enchantment.add_minor_ego_enchantments(item, ego_level)
   -- >>>>>>>> shade2/item_data.hsp:723 *item_egoMinor ...
   local count = Rand.rnd(Rand.rnd(Enchantment.MAX_RANDOM_EGO_ENCHANTMENTS)+1)+1

   for _ = 1, count do
      local enc = Enchantment.generate(item, ego_level, 0, 0, "ego_minor")
      if enc then
         item:add_enchantment(enc, 8)
      end
   end

   item.ego_minor_enchantment = rand_data_id("base.ego_minor_enchantment")
   -- <<<<<<<< shade2/item_data.hsp:729 	return ..
end

function Enchantment.ego_enchantments_for(item, ego_level)
   -- >>>>>>>> shade2/item_data.hsp:734 	p=0 ...
   local filter = function(ego)
      return ego.level == ego_level and (not ego.filter or ego.filter(item))
   end

   return data["base.ego_enchantment"]:iter():filter(filter)
   -- <<<<<<<< shade2/item_data.hsp:739 	loop ..
end

--- @hsp *item_ego
function Enchantment.add_major_ego_enchantments(item, ego_level)
   -- >>>>>>>> shade2/item_data.hsp:732 *item_ego ...
   local ego = Rand.choice(Enchantment.ego_enchantments_for(item, ego_level))

   if ego == nil then
      return
   end

   item.ego_enchantment = ego._id

   -- >>>>>>>> shade2/item_data.hsp:661 	#module ...
   for _, enc in ipairs(ego.enchantments or {}) do
      item:add_enchantment(enc._id,
         Enchantment.random_enc_power(item, enc.power),
         enc.params and table.deepcopy(enc.params) or "randomized",
         8,
         "ego"
      )
   end
   -- <<<<<<<< shade2/item_data.hsp:670 	#global ..

   if Rand.one_in(2) then
      local enc = Enchantment.generate(item, ego_level, 0, 20, "ego")
      if enc then item:add_enchantment(enc) end
   end

   if Rand.one_in(4) then
      local enc = Enchantment.generate(item, ego_level, 0, 25, "ego")
      if enc then item:add_enchantment(enc) end
   end

   -- <<<<<<<< shade2/item_data.hsp:751 	return ..
end

function Enchantment.calc_random_ego_level(item, object_level)
   if item:calc("quality") == Enum.Quality.Unique then
      return Enchantment.MAX_ENCHANTMENT_LEVEL
   else
      return Rand.rnd(math.clamp(Rand.rnd(object_level / 10 + 3), 0, Enchantment.MAX_ENCHANTMENT_LEVEL))
   end
end

--- @hsp *item_enc
function Enchantment.add_random_enchantments(item, object_level, object_quality)
   -- >>>>>>>> shade2/item_data.hsp:754 *item_enc ...
   object_level = object_level or item:calc("level")
   object_quality = object_quality or item:calc("quality")

   if object_quality <= Enum.Quality.Normal then
      return
   end

   if item.params.ammo_loaded then
      item.params.ammo_loaded = nil
   end

   local ego_level = Enchantment.calc_random_ego_level(item, object_level)

   if object_quality < Enum.Quality.Unique then
      item.value = item.value * 3
      item.identify_difficulty = 50 + Rand.rnd(math.abs(object_quality - Enum.Quality.Normal) * 100 + 100)
   end

   -- mod/elona/events/enchantments.lua
   item:emit("elona.on_add_random_enchantments", {ego_level = ego_level, level = object_level, quality = object_quality})
   -- <<<<<<<< shade2/item_data.hsp:815 	return ..
end

return Enchantment
