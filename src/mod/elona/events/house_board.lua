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
local StayingCharas = require("api.StayingCharas")
local ICharaParty = require("api.chara.ICharaParty")
local ChooseNpcMenu = require("api.gui.menu.ChooseNpcMenu")
local Enum = require("api.Enum")
local Input = require("api.Input")

local function iter_staying_allies()
   return StayingCharas.iter_global():filter(ICharaParty.is_in_player_party)
end

local function iter_allies_and_stayers(map)
   return fun.chain(Chara.player():iter_other_party_members(map), iter_staying_allies())
end


local function shop_assign_shopkeeper(map)
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

local function format_hp(chara)
   local percent = math.floor(chara.hp * 100 / chara:calc("max_hp"))
   return ("(Hp: %d%%)"):format(percent)
end

local function format_info_status(chara)
   -- >>>>>>>> shade2/command.hsp:551 			s="Lv."+cLevel(i)+" " ...
   local status_text

   -- allyCtrl=3
   if chara.state == "PetDead" then
      status_text = I18N.get("ui.ally_list.dead")
   elseif chara.state == "PetWait" then
      status_text = format_hp(chara) .. " " .. I18N.get("ui.ally_list.waiting")
   elseif chara.state == "Alive" then
      status_text = format_hp(chara)
   end

   return ("Lv.%d %s"):format(chara:calc("level"), status_text)
   -- <<<<<<<< shade2/command.hsp:558 				} ..
end

local function your_home_allies(map)
   Gui.mes("ui.ally_list.stayer.prompt")

   local topic = {
      info_formatter = format_info_status,
      window_title = "ui.ally_list.stayer.title",
   }

   local allies = iter_allies_and_stayers(map):filter(Chara.is_alive):to_list()
   local result, canceled = ChooseAllyMenu:new(allies, topic):query()

   if result and not canceled then
      Gui.play_sound("base.ok1")
      Gui.mes_newline()
      local ally = result.chara
      local staying_map = StayingCharas.get_staying_map_for_global(ally)
      if staying_map then
         if staying_map.map_uid == map.uid then
            StayingCharas.unregister_global(ally)
            Gui.mes("building.home.staying.remove.ally", ally)
         end
      else
         StayingCharas.register_global(ally, map)
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

   local candidates = Servant.iter(map):to_list()

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
