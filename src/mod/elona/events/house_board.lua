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
local ChooseAllyMenu = require("api.gui.menu.ChooseAllyMenu")
local Chara = require("api.Chara")
local StayingCharas = require("api.StayingCharas")
local ChooseNpcMenu = require("api.gui.menu.ChooseNpcMenu")
local Enum = require("api.Enum")
local Input = require("api.Input")


local function format_info_shopkeeper(chara)
   -- >>>>>>>> shade2/command.hsp:560 			if areaId(gArea)=areaShop	:s="   "+sCHR(i)+" /  ...
   return ("   %d / %d"):format(chara:skill_level("elona.stat_charisma"), chara:skill_level("elona.negotiation"))
   -- <<<<<<<< shade2/command.hsp:560 			if areaId(gArea)=areaShop	:s="   "+sCHR(i)+" /  ..
end

local function shop_assign_shopkeeper(map)
   Gui.mes("ui.ally_list.shop.prompt")

   local topic = {
      info_formatter = format_info_shopkeeper,
      window_title = "ui.ally_list.shop.title",
      header_status = "ui.ally_list.shop.chr_negotiation",
      x_offset = 20
   }

   local allies = StayingCharas.iter_allies_and_stayers(map):filter(Chara.is_alive):to_list()
   local result, canceled = ChooseAllyMenu:new(allies, topic):query()

   if result and not canceled then
      Gui.play_sound("base.ok1")

      local area, floor = Area.for_map(map)
      if not area then
         error("Map does not have an area")
      end

      local ally = result.chara
      -- TODO move elsewhere
      if map.shopkeeper_uid == ally.uid then
         StayingCharas.unregister_global(ally, area)
         map.shopkeeper_uid = nil
         Gui.mes("building.home.staying.remove.worker", ally)
      else
         if map.shopkeeper_uid then
            local existing = Building.find_worker(map, map.shopkeeper_uid)
            if existing then
               StayingCharas.unregister_global(existing, area)
            end
         end
         StayingCharas.register_global(ally, area, floor)
         map.shopkeeper_uid = ally.uid
         Gui.mes("building.home.staying.add.worker", ally)
      end
   end
end

local function shop_reform(map)
   local player = Chara.player()
   local reform_cost = ElonaBuilding.calc_shop_extend_cost(map)
   if player.gold < reform_cost then
      Gui.mes("servant.hire.not_enough_money")
      return
   end

   Gui.play_sound("base.paygold1")
   player.gold = player.gold - reform_cost
   map.item_on_floor_limit = math.clamp(map.item_on_floor_limit + 10, 1, 400)
   Gui.mes_c("building.shop.extend", "Green", map.item_on_floor_limit)
end

local function format_info_breeder(chara)
   -- >>>>>>>> shade2/command.hsp:561 			if areaId(gArea)=areaRanch	:s="   "+cBreeder(i) ...
   return ("   %d"):format(chara:calc("breed_power"))
   -- <<<<<<<< shade2/command.hsp:561 			if areaId(gArea)=areaRanch	:s="   "+cBreeder(i) ..
end

local function ranch_assign_breeder(map)
   Gui.mes("ui.ally_list.shop.prompt")

   local topic = {
      info_formatter = format_info_breeder,
      window_title = "ui.ally_list.ranch.title",
      header_status = "ui.ally_list.ranch.breed_power",
      x_offset = 20
   }

   local allies = StayingCharas.iter_allies_and_stayers(map):filter(Chara.is_alive):to_list()
   local result, canceled = ChooseAllyMenu:new(allies, topic):query()

   if result and not canceled then
      Gui.play_sound("base.ok1")

      local area, floor = Area.for_map(map)
      if not area then
         error("Map does not have an area")
      end

      local ally = result.chara
      -- TODO move elsewhere
      if map.breeder_uid == ally.uid then
         StayingCharas.unregister_global(ally, area)
         map.breeder_uid = nil
         Gui.mes("building.home.staying.remove.worker", ally)
      else
         if map.breeder_uid then
            local existing = Building.find_worker(map, map.breeder_uid)
            if existing then
               StayingCharas.unregister_global(existing, area)
            end
         end
         StayingCharas.register_global(ally, area, floor)
         map.breeder_uid = ally.uid
         Gui.mes("building.home.staying.add.worker", ally)
      end
   end
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
   Gui.mes("ui.ally_list.stayer.prompt")

   local topic = {
      window_title = "ui.ally_list.stayer.title",
      x_offset = 20
   }

   local allies = StayingCharas.iter_allies_and_stayers(map):filter(Chara.is_alive):to_list()
   local result, canceled = ChooseAllyMenu:new(allies, topic):query()

   if result and not canceled then
      Gui.play_sound("base.ok1")

      local area, floor = Area.for_map(map)
      if not area then
         error("Map does not have an area")
      end

      Gui.mes_newline()
      local ally = result.chara
      local staying_area = StayingCharas.get_staying_area_for_global(ally)
      if staying_area then
         if staying_area.area_uid == area.uid then
            StayingCharas.unregister_global(ally, area)
            Gui.mes("building.home.staying.remove.ally", ally)
         end
      else
         StayingCharas.register_global(ally, area, floor)
         Gui.mes("building.home.staying.add.ally", ally)
      end
   end
end

local function your_home_recruit_servant(map)
   Servant.query_hire()
end

local function format_wage(chara)
   -- >>>>>>>> shade2/command.hsp:1235 		if allyCtrl=1:	s=""+(calcHireCost(i)*20)+"("+cal ...
   local wage = Servant.calc_wage_cost(chara)
   return I18N.get("ui.npc_list.gold_counter", ("%d"):format(wage))
   -- <<<<<<<< shade2/command.hsp:1236 		pos wX+512,wY+66+cnt*19+2:mes s+lang(" gold","gp ..
end

local function your_home_move_stayer(map)
   local topic = {
      header_status = "ui.npc_list.init_cost",
      formatter = format_wage
   }

   local candidates = Servant.iter(map):filter(Chara.is_alive):to_list()

   Gui.mes("building.home.move.who")
   local servant, canceled = ChooseNpcMenu:new(candidates, topic):query()

   if servant and not canceled then
      if servant:relation_towards(Chara.player()) <= Enum.Relation.Enemy then
         Gui.mes("building.home.move.dont_touch_me", servant)
      else
         Gui.play_sound("base.ok1")
         local pos_x = servant.x
         local pos_y = servant.y
         while true do
            Gui.mes_newline()
            Gui.mes("building.home.move.where", servant)
            local dest_x, dest_y = Input.query_position(Chara.player(), pos_x, pos_y)
            if dest_x == nil or dest_y == "canceled" then
               break
            end
            pos_x, pos_y = dest_x, dest_y
            if not map:can_access(dest_x, dest_y) then
               Gui.mes("building.home.move.invalid")
            else
               servant:set_pos(dest_x, dest_y)
               servant.initial_x = servant.x
               servant.initial_y = servant.y
               servant:remove_activity()
               Gui.mes_newline()
               Gui.mes("building.home.move.is_moved", servant)
               Gui.play_sound("base.foot", servant.x, servant.y)
               break
            end
         end
      end
   end

   Gui.update_screen()
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
