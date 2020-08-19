local Map = require("api.Map")
local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Charagen = require("mod.tools.api.Charagen")
local InstancedMap = require("api.InstancedMap")
local Enum = require("api.Enum")
local Util = require("mod.elona_sys.api.Util")
local Resolver = require("api.Resolver")

local Calc = {}

function Calc.calc_object_level(base, map)
   assert(class.is_an(InstancedMap, map), "Map must be provided")

   local ret = base or 0
   if base < 0 then
      ret = map:calc("level")
   end

   local map_base = map:calc("base_object_level")
   if map_base then
      ret = map_base
   end

   for i=1, 3 do
      if Rand.one_in(30 + i * 5) then
         ret = ret + Rand.rnd(10 + i)
      else
         break
      end
   end

   if base <= 3 and not Rand.one_in(4) then
      ret = Rand.rnd(3) + 1
   end

   return ret
end

function Calc.calc_object_quality(quality)
   assert(Enum.Quality:has_value(quality))

   local ret = quality or 2
   if ret == 0 then
      ret = 2
   end

   for i=1, 3 do
      local n = Rand.rnd(30 + i * 5)
      if n == 0 then
         ret = ret + 1
      elseif n < 3 then
         ret = ret - 1
      else
         break
      end
   end

   return math.clamp(ret, 1, 5)
end

function Calc.filter(level, quality, rest, map)
   map = map or Map.current()

   return table.merge({
      level = Calc.calc_object_level(level, map),
      quality = Calc.calc_object_quality(quality),
   }, rest or {})
end

function Calc.calc_fame_gained(chara, base)
   local ret = math.floor(base * 100 / (100 + chara.fame / 100 * (chara.fame / 100) / 2500))
   if ret < 5 then
      ret = Rand.rnd(5) + 1
   end
   return ret
end

function Calc.hunt_enemy_id(difficulty, min_level)
   local id

   for _ = 1, 50 do
      local chara = Charagen.create(nil, nil, { level = difficulty, quality = 2, ownerless = true })
      id = chara._id
      if not chara.is_shade and chara.level >= min_level then
         break
      end
   end

   return id
end

function Calc.round_margin(a, b)
   if a > b then
      return a - Rand.rnd(a - b)
   elseif a < b then
      return a + Rand.rnd(b - a)
   else
      return a
   end
end

function Calc.make_sound(chara, map)
   -- TODO
end

function Calc.make_guards_hostile(map)
   -- TODO
end

-- @tparam IItem item
-- @tparam string mode "buy" (default), "sell", "player_shop"
-- @tparam boolean is_shop
-- @treturn int
function Calc.calc_item_value(item, mode, is_shop)
   local elona_Item = require("mod.elona.api.Item")

   mode = mode or "buy"

   local player = Chara.player()
   local identify = item:calc("identify_state")
   local curse = item:calc("curse_state")
   local base_value = item:calc("value")
   local value
  
   -- shade2/calculation.hsp:595 #defcfunc calcItemValue int id ,int mode ..
   if identify == Enum.IdentifyState.None then
      if mode == "player_shop" then
         value = base_value * 4 / 10
      else
         local pc_level = player:calc("level")
         value = pc_level / 5 * ((save.base.random_seed + Util.string_to_integer(item._id) * 31) % pc_level + 4) + 10
      end
   else
      if elona_Item.is_equipment(item) then
         if     identify == Enum.IdentifyState.Name then
            value = base_value * 2 / 10
         elseif identify == Enum.IdentifyState.Quality then
            value = base_value * 5 / 10
         elseif identify >= Enum.IdentifyState.Full then
            value = base_value
         end
      else
         value = base_value
      end
   end

   if identify >= Enum.IdentifyState.Full then
      if curse == Enum.CurseState.Blessed then
         value = value * 120 / 100
      elseif curse == Enum.CurseState.Cursed then
         value = value / 2
      elseif curse == Enum.CurseState.Doomed then
         value = value / 5
      end
   end

   if item:has_category("elona.food") then
      if (item.params.food_quality or 0) > 0 then
         value = value * item.params.food_quality * item.params.food_quality / 10
      end
   end
   if item:has_category("elona.cargo_food") and mode == "buy" then
      local fame = player:calc("fame")
      value = value + math.clamp(fame / 40 + value * (fame / 80) / 100, 0, 800)
   end

   local cargo_weight = item:calc("cargo_weight") or 0
   if cargo_weight > 0 and is_shop and item:has_category("elona.cargo") then
      -- TODO cargo rate fluctuation
      local trade_rate = 1
      value = value * trade_rate / 100
      if mode == "sell" then
         return math.floor(value * 65 / 100)
      else
         return math.floor(value)
      end
   end

   if item:calc("has_charge") and item.charges then
      if item.charges < 0 then
         value = value / 10
      else
         if item:has_category("elona.spellbook") then
            value = value / 5 + value * item.charges / (item:calc("charge_level") * 2 + 1)
         else
            value = value / 2 + value * item.charges / (item:calc("charge_level") * 3 + 1)
         end
      end
   end

   if item:has_category("elona.container") then
      if (item.params.chest_item_level or 0) == 0 then
         value = value / 100 + 1
      end
   end

   local negotiation = player:skill_level("elona.negotiation")

   if mode == "buy" then
      local value_limit = value / 2
      value = value * 100 / (100 + negotiation)
      -- TODO mage guild
      value = math.max(value, value_limit)
   elseif mode == "sell" then
      local value_limit = negotiation * 250 + 5000
      value = math.max(value / 3, value_limit)
      value = value * (100 + negotiation * 5) / 1000
      if elona_Item.is_equipment(item) then
         value = value / 20
      end
      if item:calc("is_stolen") then
         -- TODO thief guild
      end
      value = math.min(value, value_limit)
   elseif mode == "player_shop" then
      value = value / 5
      if elona_Item.is_equipment(item) then
         value = value / 3
      end
      value = math.min(value, 15000)
      if item:calc("is_stolen") then
         value = 1
      end
   end

   if config["base.development_mode"] and value <= 0 then
      value = 1
   end

   return math.floor(value)
   -- <<<<<<<< shade2/calculation.hsp:670 	return value ..
end

-- >>>>>>>> shade2/calculation.hsp:802 #defcfunc calcTrainCost int id,int c,int mode ..
function Calc.calc_train_cost(skill_id, chara)
   return math.floor(chara:base_skill_level(skill_id) / 5 + 2)
end
-- <<<<<<<< shade2/calculation.hsp:811 	return value ..

-- >>>>>>>> shade2/calculation.hsp:815 #defcfunc calcLearnCost int id,int c,int mode ..
function Calc.calc_learn_cost(skill_id, chara)
   return math.floor(15 + 3 * save.elona.total_skills_learned)
end
-- <<<<<<<< shade2/calculation.hsp:818 	return value ...

return Calc
