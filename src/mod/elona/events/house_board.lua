local Event = require("api.Event")
local Building = require("mod.elona.api.Building")
local ElonaBuilding = require("mod.elona.api.ElonaBuilding")
local I18N = require("api.I18N")
local Map = require("api.Map")

local function shop_assign_shopkeeper(map)
end

local function shop_reform(map)
end

local function ranch_assign_breeder(map)
end

local function design(map)
end

local function your_home_home_rank(map)
   HomeRankMenu:new(map):query()
end

local function your_home_allies(map)
end

local function your_home_recruit_servant(map)
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

   if map._archetype == "elona.your_home" then
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
