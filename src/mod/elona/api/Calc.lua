local Map = require("api.Map")
local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Charagen = require("mod.tools.api.Charagen")
local InstancedMap = require("api.InstancedMap")
local Enum = require("api.Enum")
local Util = require("mod.elona_sys.api.Util")
local Const = require("api.Const")

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

   if config.base.development_mode and value <= 0 then
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

function Calc.calc_trainer_skills(trainer, player)
   local skills = {
      "elona.detection",
      "elona.evasion"
   }

   local map = trainer:current_map()

   if map and map.trainer_skills then
      skills = table.imerge(skills, map.trainer_skills)
   end

   skills = fun.iter(skills)
      :filter(function(skill_id)
            return not player:has_skill(skill_id)
             end)
      :to_list()

   return skills
end

function Calc.calc_tax_multiplier(player)
   -- >>>>>>>> shade2/calculation.hsp:710 #define calcAccountant 	cost=cost * limit(100-limi ..
   local karma = player:calc("karma")
   local tax_trait_level = player:trait_level("elona.tax")
   return math.clamp(100 - math.clamp(karma/2, 0, 50) - (7 * tax_trait_level) - (((karma >= Const.KARMA_GOOD) and 5) or 0), 25, 200) / 100
   -- <<<<<<<< shade2/calculation.hsp:710 #define calcAccountant 	cost=cost * limit(100-limi ..
end

function Calc.calc_building_taxes(player)
   local cost = 0

   cost = cost + save.elona.home_rank ^ 2 * 200
   for _, building in ipairs(save.elona.player_owned_buildings) do
      cost = cost + building.tax_cost
   end

   cost = cost * Calc.calc_tax_multiplier(player)

   return cost
end

function Calc.calc_living_weapon_required_exp(level)
   return level * 100
end

function Calc.calc_give_carry_weight(chara)
   -- >>>>>>>> shade2/command.hsp:3773 			p=(sSTR(tc)*500+sEND(tc)*500+sWeightLifting(tc) ...
   local weight = chara:skill_level("elona.stat_strength") * 500
      + chara:skill_level("elona.stat_constitution")* 500
      + chara:skill_level("elona.weight_lifting")* 2500
      + 25000

   if chara._id == "elona.golden_knight" then
      weight = weight * 5
   end

   return weight
   -- <<<<<<<< shade2/command.hsp:3774 			if cId(tc)=265:p*=5 ..
end

function Calc.will_chara_take_item(target, item, amount)
   -- >>>>>>>> shade2/command.hsp:3772 			f=false ...
   local carry_weight = Calc.calc_give_carry_weight(target)

   if target.inventory_weight + item.weight * amount > carry_weight then
      return false, "ui.inv.give.refuse_dialog.too_heavy"
   end

   if target._id ~= "elona.golden_knight" then
      if item:has_category("elona.furniture") then
         return false, "ui.inv.give.refuse_dialog.is_furniture"
      end
      if item:has_category("elona.junk") then
         return false, "ui.inv.give.refuse_dialog.is_junk"
      end
   end

   if item:calc("cargo_weight") > 0 then
      return false, "ui.inv.give.refuse_dialog.is_cargo"
   end

   -- <<<<<<<< shade2/command.hsp:3784 			} ..

   -- >>>>>>>> shade2/command.hsp:3786 			f=false ...
   if target:is_ally() then
      return true
   end

   if item:calc("identify_state") < Enum.IdentifyState.Quality then
      return false, "ui.inv.give.too_creepy"
   end

   if item:calc("curse_state") <= Enum.CurseState.Cursed then
      return false, "ui.inv.give.cursed"
   end

   if item:has_tag("neg") or item:has_tag("nogive") then
      return false
   end

   if item:has_category("elona.drink") then
      if item:has_category("elona.drink_alcohol") and target:has_effect("elona.drunk") then
         return false, "ui.inv.give.no_more_drink"
      end
   end

   return true
   -- <<<<<<<< shade2/command.hsp:3815 			} ..
end

function Calc.will_chara_give_item_back(target, item, amount)
   -- >>>>>>>> shade2/command.hsp:3922 			f=0 ...
   if item:has_category("elona.ore") then
      return false, "ui.inv.take_ally.refuse_dialog"
   end

   return true
   -- <<<<<<<< shade2/command.hsp:3928  ..
end

return Calc
