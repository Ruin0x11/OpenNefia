local Map = require("api.Map")
local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Charagen = require("mod.elona.api.Charagen")
local Enum = require("api.Enum")
local Util = require("mod.elona_sys.api.Util")
local Const = require("api.Const")
local Rank = require("mod.elona.api.Rank")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.elona.api.Itemgen")
local Item = require("api.Item")

local Calc = {}

function Calc.calc_object_level(base, map)
   local ret = base or 0
   if ret <= 0 then
      if map then
         ret = map:calc("level")
      else
         ret = 1
      end
   end

   if map then
      local map_base = map:calc("base_object_level")
      if map_base then
         ret = map_base
      end
   end

   for i=1, 3 do
      if Rand.one_in(30 + i * 5) then
         ret = ret + Rand.rnd(10 + i)
      else
         break
      end
   end

   if ret <= 3 and not Rand.one_in(4) then
      ret = Rand.rnd(3) + 1
   end

   return ret
end

function Calc.calc_object_quality(quality)
   local ret = quality or Enum.Quality.Normal
   if ret == 0 then
      ret = Enum.Quality.Normal
   end

   assert(Enum.Quality:has_value(ret))

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

-- @tparam IItem item
-- @tparam string mode "buy" (default), "sell", "player_shop"
-- @tparam boolean is_shop
-- @treturn int
function Calc.calc_item_value(item, mode, is_shop)
   local ElonaItem = require("mod.elona.api.ElonaItem")

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
      if ElonaItem.is_equipment(item) then
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
      if player:calc("guild") == "elona.mage" and item:has_category("elona.spellbook") then
         value = value * 80 / 100
      end
      value = math.max(value, value_limit)
   elseif mode == "sell" then
      local value_limit = negotiation * 250 + 5000
      if value / 3 < value_limit then
         value_limit = value / 3
      end
      value = value * (100 + negotiation * 5) / 1000
      if ElonaItem.is_equipment(item) then
         value = value / 20
      end
      if item.is_stolen then
         if player:calc("guild") == "elona.thief" then
            value = value / 3 * 2
         else
            value = value / 10
         end
      end
      value = math.min(value, value_limit)
   elseif mode == "player_shop" then
      value = value / 5
      if ElonaItem.is_equipment(item) then
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

function Calc.calc_item_medal_value(item)
   return item:calc("medal_value") or 0
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

function Calc.calc_building_expenses(player)
   -- >>>>>>>> shade2/calculation.hsp:719 #defcfunc calcCostBuilding ...
   local cost = 0

   local home = data["elona.home"]:ensure(save.elona.home_rank)
   local scale = home.home_scale or 0
   cost = cost + scale ^ 2 * 200
   for _, building in ipairs(save.elona.player_owned_buildings) do
      cost = cost + (building.tax_cost or 0)
   end

   return Calc.calc_adjusted_expense(cost, player)
   -- <<<<<<<< shade2/calculation.hsp:730 	return cost ..
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

function Calc.calc_innkeeper_meal_cost()
   -- >>>>>>>> shade2/calculation.hsp:741 #defcfunc calcMealValue  ...
   return 140
   -- <<<<<<<< shade2/calculation.hsp:743 	return value ..
end

function Calc.calc_random_site_generate_count(map)
   -- >>>>>>>> shade2/map.hsp:2214 			p=rnd(mHeight*mWidth/400+3)  ...
   local amount = Rand.rnd(map:width() * map:height() / 400 + 3)

   if map:has_type("world_map") then
      amount = Rand.rnd(40)
   end

   if map:has_type("town") then
      amount = Rand.rnd(Rand.rnd(Rand.rnd(12)+1)+1)
   end

   if map:has_type("guild") then
      amount = Rand.rnd(amount + 1)
   end

   return amount
   -- <<<<<<<< shade2/map.hsp:2217 			if mType=mTypeVillage	: p=rnd(p+1) ..
end

function Calc.calc_player_sleep_hours(player)
   return 7 + Rand.rnd(5)
end

function Calc.calc_rank_income(rank_id, rank_exp)
   -- >>>>>>>> shade2/event.hsp:408 #module ...
   local exp = rank_exp or Rank.get(rank_id)

   if exp >= 10000 then
      return 0
   end

   local income = math.floor(100 - (exp / 100))
   if income == 99 then
      income = income * 70
   else
      income = income * 50
   end

   local proto = data["elona.rank"]:ensure(rank_id)
   if proto.calc_income then
      income = proto.calc_income(income, exp)
   end

   return math.floor(income)
   -- <<<<<<<< shade2/event.hsp:421 #global ..
end

function Calc.calc_fame_income(chara)
   chara = chara or Chara.player()
   if not chara then
      return 0
   end

   -- >>>>>>>> shade2/command.hsp:946 	gold=0	 ...
   local fame = chara and chara:calc("fame")
   local gold = math.clamp(fame / 10, 100, 25000)
   if fame >= 25000 then
      gold = gold + (fame - 25000) / 100
   end

   return math.floor(gold)
   -- <<<<<<<< shade2/command.hsp:949 	gold+=p		 ..
end

--- Calculates the salary amount displayed in the journal.
function Calc.calc_displayed_total_income(chara)
   -- >>>>>>>> shade2/command.hsp:946 	gold=0	 ...
   local fame_income = Calc.calc_fame_income(chara)
   local rank_income = Rank.iter():map(function(r) return Calc.calc_rank_income(r._id) end):sum()

   return fame_income + rank_income
   -- <<<<<<<< shade2/command.hsp:970 	loop ..
end

function Calc.calc_actual_rank_income(rank_id)
   local base_income = Calc.calc_rank_income(rank_id)
   return base_income + Rand.rnd(base_income / 3 + 1) - Rand.rnd(base_income / 3 + 1)
end

--- Calculates the actual gold income accounting for randomization
function Calc.calc_actual_income(chara)
   -- >>>>>>>> shade2/event.hsp:439 	income=0,0 ...
   local fame_income = Calc.calc_fame_income(chara)

   local rank_income = Rank.iter()
     :extract("_id")
     :map(Calc.calc_actual_rank_income):sum()

   return fame_income + rank_income
   -- <<<<<<<< shade2/event.hsp:465 		} ..
end

function Calc.generate_rank_income_item(rank_id, chara, place)
   -- >>>>>>>> shade2/event.hsp:451 	dbId=0 ...
   place = place or Rank.get(rank_id)

   local level = (100 - (place / 100)) / 2 + 1
   local quality = Enum.Quality.Good
   if chara and Rand.rnd(12) < chara:trait_level("elona.good_pay") then
      quality = Enum.Quality.Great
   end

   local filter = {
      level = Calc.calc_object_level(level),
      quality = Calc.calc_object_quality(quality),
      categories = Rand.choice(Filters.fsetincome),
      is_shop = true
   }
   if Rand.one_in(5) then
      filter.categories = Rand.choice(Filters.fsetwear)
   end
   if Rand.rnd(100 + place / 5) < 2 then
      filter.id = "elona.potion_of_cure_corruption"
   end

   filter.ownerless = true
   return Itemgen.create(nil, nil, filter)
   -- <<<<<<<< shade2/event.hsp:457 	item_create -1 ,dbId: income(1)++ ..
end

function Calc.calc_rank_income_item_amount(rank_id, chara)
   -- >>>>>>>> shade2/event.hsp:449 	p=rnd(rnd(3)+1)+1:cnt2=cnt	 ...
   return Rand.rnd(Rand.rnd(3) + 1) + 1
   -- <<<<<<<< shade2/event.hsp:449 	p=rnd(rnd(3)+1)+1:cnt2=cnt	 ..
end

function Calc.calc_rank_income_items(rank_id, chara, place)
   chara = chara or Chara.player()
   place = place or Rank.get(rank_id)
   local proto = data["elona.rank"]:ensure(rank_id)

   if place >= 10000 then
      return {}
   end

   if not proto.provides_salary_items then
      return {}
   end

   local gen_item = function()
      return Calc.generate_rank_income_item(rank_id, chara)
   end

   local amount = Calc.calc_rank_income_item_amount(rank_id, chara)
   return fun.tabulate(gen_item):take(amount):to_list()
end

function Calc.calc_income_items(chara)
   -- >>>>>>>> shade2/event.hsp:440 	repeat tailRank ...
   return Rank.iter()
      :extract("_id")
      :flatmap(function(rank_id) return Calc.calc_rank_income_items(rank_id, chara) end)
      :to_list()
   -- <<<<<<<< shade2/event.hsp:459 	loop ..
end

--- Calculates an expense in gold, taking karma and the Accountant trait into
--- consideration.
function Calc.calc_adjusted_expense(cost, player)
   -- >>>>>>>> shade2/calculation.hsp:706 #define calcAccountant 	cost=cost * limit(100-limi ...
   player = player or Chara.player()
   local karma = player:calc("karma")
   local factor = math.clamp(100 - karma / 2, 0, 50) - (7 * player:trait_level("elona.tax"))

   if karma >= Const.KARMA_GOOD then
      factor = factor - 5
   end

   factor = math.clamp(factor, 25, 100)

   return math.floor(cost * factor / 100)
   -- <<<<<<<< shade2/calculation.hsp:706 #define calcAccountant 	cost=cost * limit(100-limi ..
end

function Calc.calc_tax_expenses(chara)
   -- >>>>>>>> shade2/calculation.hsp:733 #defcfunc calcCostTax	 ...
   chara = chara or Chara.player()

   local cost = 0
   cost = cost + chara.gold / 1000
   cost = cost + chara:calc("fame")
   cost = cost + chara:calc("level") * 200

   return Calc.calc_adjusted_expense(cost, chara)
   -- <<<<<<<< shade2/calculation.hsp:739 	return cost ..
end

function Calc.calc_base_bill_amount(chara)
   local labor_expenses = save.elona.labor_expenses
   local building_expenses = Calc.calc_building_expenses(chara)
   local tax_expenses = Calc.calc_tax_expenses(chara)

   return labor_expenses + building_expenses + tax_expenses
end

function Calc.calc_actual_bill_amount(chara)
   -- >>>>>>>> shade2/event.hsp:486 		iSubName(ci)=gCostHire+calcCostBuilding()+calcCo ...
   local base_amount = Calc.calc_base_bill_amount(chara)
   return math.floor(base_amount * (100 + Rand.rnd(20)) / 100)
   -- <<<<<<<< shade2/event.hsp:487 		iSubName(ci)=iSubName(ci)*(100+rnd(20))/100 ..
end

function Calc.calc_ally_limit(chara)
   -- >>>>>>>> shade2/init.hsp:3174 #define global followerLimit limit(sCHR(pc)/5+1,2, ...
   return math.floor(math.clamp(chara:skill_level("elona.stat_charisma") / 5 + 1, 2, Const.MAX_CHARAS_ALLY))
   -- <<<<<<<< shade2/init.hsp:3174 #define global followerLimit limit(sCHR(pc)/5+1,2, ..
end

-- @tparam string kind "identify", "investigate"
-- @hsp calcIdentifyValue kind
function Calc.calc_item_identify_cost(item, kind, player)
   kind = kind or "identify"
   player = player or Chara.player()

   local cost = 300
   if kind == "identify" then
      local filter = function(i) return Item.is_alive(i) and i.identify_state < Enum.IdentifyState.Full end
      local known_count = player:iter_items():filter(filter):length()
      if known_count >= 2 then
         cost = cost * known_count * 70 / 100
      end
   elseif kind == "investigate" then
      cost = 5000
   end

   cost = cost * 100 / (100 + player:skill_level("elona.negotiation") * 2)

   if player:calc("guild") == "elona.fighter" then
      cost = cost / 2
   end

   return math.floor(cost)
end

function Calc.calc_restore_cost(chara)
   local cost = 500

   if chara:calc("guild") == "elona.fighter" then
      cost = cost / 2
   end

   return math.floor(cost)
end

function Calc.calc_informer_investigate_cost(player, ally)
   return 10000
end

function Calc.calc_cargo_limit_upgrade_cost(chara)
   return (chara.max_cargo_weight - chara.initial_max_cargo_weight) / 10000 + 1
end

function Calc.calc_cargo_limit_upgrade_amount(chara)
   return 10000
end

return Calc
