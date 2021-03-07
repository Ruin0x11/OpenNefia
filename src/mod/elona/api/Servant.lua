local Chara = require("api.Chara")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local ChooseNpcMenu = require("api.gui.menu.ChooseNpcMenu")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Calc = require("mod.elona.api.Calc")
local Home = require("mod.elona.api.Home")

local Servant = {}

-- >>>>>>>> shade2/item.hsp:56 	iSetHire=205,70,74,41,69,76,idShopKeeper,idShopKe ...
local CANDIDATES = {
   { _id = "elona.maid",      role = "elona.maid" },
   { _id = "elona.bartender", role = "elona.bartender" },
   { _id = "elona.healer",    role = "elona.healer" },
   { _id = "elona.wizard",    role = "elona.identifier" },
   { _id = "elona.informer",  role = "elona.informer" },
   { _id = "elona.shopkeeper" },
   { _id = "elona.shopkeeper" },
   { _id = "elona.shopkeeper" },
}
-- <<<<<<<< shade2/item.hsp:61 	iSetHireRole=cRoleMaid,cRoleBarten,cRoleHealer,cR ..

-- >>>>>>>> shade2/map_user.hsp:398 		if p=0: cRole(rc)=cRoleShopArmor	:cnName(rc)=lan ...
local SHOP_KINDS = {
   { _id = "elona.blacksmith",    name = "servant.shop_title.armory" },
   { _id = "elona.general_store", name = "servant.shop_title.general_store" },
   { _id = "elona.magic_vendor",  name = "servant.shop_title.magic_store" },
   { _id = "elona.general_store", name = "servant.shop_title.goods_store" },
   { _id = "elona.blackmarket",   name = "servant.shop_title.blackmarket" },
}
-- <<<<<<<< shade2/map_user.hsp:403 		if p=5:	cRole(rc)=cRoleShopBlack	:cnName(rc)=lan ..

-- >>>>>>>> shade2/calculation.hsp:684 	if cRole(tc)=cRoleMaid		:value=450 ...
local WAGES = {
   ["elona.maid"] = 450,
   ["elona.trainer"] = 250,
   ["elona.bartender"] = 350,
   ["elona.healer"] = 500,
   ["elona.identifier"] = 750,
   ["elona.informer"] = 250,
   ["elona.guard"] = 50,
   ["elona.shopkeeper"] = 1000
}

local SHOPKEEPER_WAGES = {
   ["elona.blackmarket"] = 4000
}
-- <<<<<<<< shade2/calculation.hsp:695 		} ...

function Servant.generate(candidate)
   -- >>>>>>>> shade2/map_user.hsp:391 	if cnt=0:hire=0:else:hire=rnd(length(iSetHire)) ...
   candidate = candidate or Rand.choice(CANDIDATES)
   local chara
   if candidate._id == "elona.shopkeeper" then
      chara = Chara.create("elona.shopkeeper", nil, nil, {ownerless=true})

      local shop_kind = Rand.choice(SHOP_KINDS)
      data["elona.shop_inventory"]:ensure(shop_kind._id)
      chara:add_role("elona.shopkeeper", { inventory_id = shop_kind._id })
      chara.name = I18N.get(shop_kind.name, chara)

      Rand.set_seed()
      chara.shop_rank = Rand.rnd(15) + 1
   else
      chara = Chara.create(candidate._id, nil, nil, {ownerless=true})
      chara:add_role(candidate.role)
   end

   return chara
   -- <<<<<<<< shade2/map_user.hsp:405 		} ..
end

local function roles_match(cand)
   return function(other)
      return table.deepcompare(cand.roles, other.roles)
   end
end

function Servant.generate_hiring_candidates(map)
   local set_seed = not config.base.development_mode

   local function generate(i)
      if set_seed then Rand.set_seed(save.base.date.hour) end

      if Rand.one_in(2) then
         return nil
      end

      local candidate
      if i == 1 then
         candidate = CANDIDATES[1] -- maid
      end

      if set_seed then Rand.set_seed(save.base.date.hour) end
      local cand = Servant.generate(candidate)

      if Chara.iter_all(map):any(roles_match(cand)) then
         return nil
      end

      return cand
   end

   return fun.range(10):map(generate):filter(fun.op.truth):to_list()
end

function Servant.calc_hire_cost(chara)
   return Servant.calc_wage_cost(chara) * 20
end

function Servant.calc_wage_cost(chara)
   -- >>>>>>>> shade2/calculation.hsp:682 #defcfunc calcHireCost int tc ...
   local wage = 0

   for _, role in chara:iter_roles() do
      if role._id == "elona.shopkeeper" then
         wage = wage + (SHOPKEEPER_WAGES[role.inventory_id] or 1000)
      else
         wage = wage + (WAGES[role._id] or 0)
      end
   end

   return wage
   -- <<<<<<<< shade2/calculation.hsp:697 	return value ..
end

function Servant.is_servant(chara)
   local map = chara:current_map()
   return (map and Home.is_home(map)
              and chara:has_any_roles()
              -- Lomias, Larnneire, etc. should not be moveable through the
              -- house board.
              and not chara:find_role("elona.special"))
      or false
end

function Servant.calc_max_servant_limit(map)
   return (map.home_scale or 0) + 2
end

-- TODO support multiple homes
function Servant.calc_total_labor_expenses(map)
   -- >>>>>>>> shade2/calculation.hsp:708 #deffunc calcCostHire ...
   local total = 0

   for _, chara in Chara.iter(map):filter(Servant.is_servant) do
      total = total + Servant.calc_wage_cost(chara)
   end

   return Calc.calc_adjusted_expense(total)
   -- <<<<<<<< shade2/calculation.hsp:717 	return ..
end

function Servant.query_hire()
   local player = Chara.player()
   local map = player:current_map()

   if not map:has_type("player_owned") then
      return
   end

   local function format_hire_cost_and_wage(chara)
      -- >>>>>>>> shade2/command.hsp:1235 		if allyCtrl=1:	s=""+(calcHireCost(i)*20)+"("+cal ...
      local hire_cost = Servant.calc_hire_cost(chara)
      local wage = Servant.calc_wage_cost(chara)
      return I18N.get("ui.npc_list.gold_counter", ("%d(%d)"):format(hire_cost, wage))
      -- <<<<<<<< shade2/command.hsp:1236 		pos wX+512,wY+66+cnt*19+2:mes s+lang(" gold","gp ..
   end

   local topic = {
      title = "ui.npc_list.init_cost",
      formatter = format_hire_cost_and_wage
   }

   local candidates = Servant.generate_hiring_candidates(map)

   Gui.mes("servant.hire.who")
   local servant, canceled = ChooseNpcMenu:new(candidates, topic):query()

   if servant and not canceled then
      Gui.mes_newline()
      local hire_cost = Servant.calc_hire_cost(servant)
      if player.gold < hire_cost then
         Gui.mes("servant.hire.not_enough_money")
      else
         Gui.play_sound("base.paygold1")
         player.gold = math.floor(player.gold - hire_cost)
         Gui.wait(250)
         Gui.mes_c("building.home.hire.you_hire", "Green", servant)
         Map.try_place_chara(servant, player.x, player.y, map)
         Gui.play_sound("base.pray1")
      end
   end

   save.elona.labor_expenses = Servant.calc_total_labor_expenses(map)
end

return Servant
