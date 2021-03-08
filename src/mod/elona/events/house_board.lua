local Event = require("api.Event")
local Building = require("mod.elona.api.Building")
local ElonaBuilding = require("mod.elona.api.ElonaBuilding")
local I18N = require("api.I18N")
local Map = require("api.Map")
local Home = require("mod.elona.api.Home")
local HomeRankMenu = require("mod.elona.api.gui.HomeRankMenu")
local Servant = require("mod.elona.api.Servant")
local MapEdit = require("mod.elona.api.MapEdit")
local Gui = require("api.Gui")
local Area = require("api.Area")
local Log = require("api.Log")
local ChooseAllyMenu = require("api.gui.menu.ChooseAllyMenu")
local Chara = require("api.Chara")

local function shop_assign_shopkeeper(map)
   if not Building.map_is_building(map, "elona.shop") then
      Gui.mes("common.it_is_impossible")
      return
   end

   -- TODO multiple shop maps per area (#178)
   local area = Area.for_map(map)
   if area == nil then
      Log.error("Shop map '%d' is not in an area.", map.uid)
      Gui.mes("common.it_is_impossible")
      return
   end

end

local function shop_reform(map)
end

local function ranch_assign_breeder(map)
end

local function design(map)
   MapEdit.start()
end

local function your_home_home_rank(map)
   local most_valuable = Home.calc_most_valuable_items(map)
   local _rank, base_value, home_value, furniture_value = Home.update_rank(map)
   HomeRankMenu:new(most_valuable, base_value, home_value, furniture_value):query()
end

local function your_home_allies(map)
end

local function your_home_recruit_servant(map)
   Servant.query_hire()
end

local function your_home_move_stayer(map)
end

local function add_house_board_actions(map, params, actions)
   local function add_option(text, callback)
      table.insert(actions, { text = text, callback = callback })
   end

   -- >>>>>>>> shade2/map_user.hsp:224 	if areaId(gArea)=areaShop{ ...
   if Building.map_is_building(map, "elona.shop") then
      add_option("building.house_board.choices.assign_a_shopkeeper", shop_assign_shopkeeper)

      if map.item_on_floor_limit < 400 then
         local reform_cost = ElonaBuilding.calc_shop_extend_cost(map)
         add_option(I18N.get("building.house_board.choices.extend", reform_cost), shop_reform)
      end
   elseif Building.map_is_building(map, "elona.ranch") then
      add_option("building.house_board.choices.assign_a_breeder", ranch_assign_breeder)
   end

   add_option("building.house_board.choices.design", design)

   if Home.is_home(map) then
      add_option("building.house_board.choices.home_rank", your_home_home_rank)
      add_option("building.house_board.choices.allies_in_your_home", your_home_allies)
      if Map.floor_number(map) == 1 then
         add_option("building.house_board.choices.recruit_a_servant", your_home_recruit_servant)
      end
      add_option("building.house_board.choices.move_a_stayer", your_home_move_stayer)
   end
   -- <<<<<<<< shade2/map_user.hsp:240 		} ..

   return actions
end
Event.register("elona.on_build_house_board_actions", "Build default options", add_house_board_actions)
