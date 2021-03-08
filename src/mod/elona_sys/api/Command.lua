local Action = require("api.Action")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Map = require("api.Map")
local Pos = require("api.Pos")
local EquipmentMenu = require("api.gui.menu.EquipmentMenu")
local Save = require("api.Save")
local elona_Magic = require("mod.elona.api.Magic")
local QuickMenuPrompt = require("api.gui.QuickMenuPrompt")
local Log = require("api.Log")
local ConfigMenuWrapper = require("api.gui.menu.config.ConfigMenuWrapper")
local Prompt = require("api.gui.Prompt")
local Feat = require("api.Feat")
local JournalMenu = require("api.gui.menu.JournalMenu")

--- Game logic intended for the player only.
local Command = {}

local function travel_to_map_hook(source, params, result)
   assert(Map.travel_to(params.outer_map, { start_x = params.x, start_y = params.y }))

   return "player_turn_query"
end
Event.register("elona_sys.on_travel_to_outer_map", "Hook when traveling to a new map.", travel_to_map_hook)

function Command.move(player, x, y)
   if type(x) == "string" then
      x, y = Pos.add_direction(x, player.x, player.y)
   end

   -- Try to modify the final position or prevent movement. This is caused by
   -- status effects like confusion, or being overweight, respectively.
   local next_pos = player:emit("elona_sys.before_player_move", {}, {x=x,y=y,result=nil})
   if next_pos.result then
      return next_pos.result or "player_turn_query"
   end

   player.direction = Pos.pack_direction(Pos.direction_in(player.x, player.y, next_pos.x, next_pos.y))

   -- At this point the next position is final.

   local on_cell = Chara.at(next_pos.x, next_pos.y)
   if on_cell then
      if on_cell:is_player() then
         return "turn_end"
      else
         local result = player:emit("elona_sys.on_player_bumped_into_chara", {chara=on_cell}, "turn_end")

         return result
      end
   end

   -- >>>>>>>> shade2/action.hsp:581 	if (gLevel=1)or(mType=mTypeField):if mType!mTypeW ..
   local map = player:current_map()
   local prev_map_uid, prev_x, prev_y = map:previous_map_and_location()

   if not Map.is_in_bounds(next_pos.x, next_pos.y, map) then
      local can_exit_from_edge = not Map.is_world_map(map) and Map.exists(prev_map_uid)
      if can_exit_from_edge then
         local ok, prev_map = Map.load(prev_map_uid)
         if prev_map and prev_x and prev_y then
            -- Player is trying to move out of the map.
            Gui.mes("action.move.leave.prompt", map.name)
            Event.trigger("elona_sys.before_player_map_leave", {player=player})

            if Input.yes_no() then
               Gui.play_sound("base.exitmap1")
               Gui.update_screen()

               local result = Event.trigger("elona_sys.on_travel_to_outer_map", {outer_map=prev_map, x=prev_x, y=prev_y}, "player_turn_query")
               return result
            end

            return "player_turn_query"
         end
      end
   else
      for _, obj in Map.current():objects_at_pos(next_pos.x, next_pos.y) do
         if obj:calc("is_solid") then
            Input.halt_input()
            local result = obj:emit("elona_sys.on_bump_into", {chara=player}, nil)
            if result then
               return "turn_end"
            end
         end
      end

      -- Run the general-purpose movement command. This will also
      -- handle blocked tiles.

      Action.move(player, next_pos.x, next_pos.y)
      Gui.set_scroll()
   end

   -- proc confusion text

   return "turn_end"
   -- >>>>>>>> shade2/action.hsp:598 		} ..
end

function Command.get(player)
   -- TODO: plants
   -- traps
   -- buildings
   -- snow
   local result = player:emit("elona_sys.on_get")
   if result then
      return "turn_end"
   end

   local items = Item.at(player.x, player.y):to_list()
   if #items == 0 then
      Gui.mes("action.get.air")
      return "turn_end"
   end

   if #items == 1 then
      local item = items[1]
      Item.activate_shortcut(item, "elona.inv_get", { chara = player })
      return "turn_end"
   end

   local result, canceled = Input.query_inventory(player, "elona.inv_get", nil, nil)
   if canceled then
      return nil, canceled
   end
   return result.result
end

function Command.drop(player)
   local result, canceled = Input.query_inventory(player, "elona.inv_drop", nil, "elona.main")
   if canceled then
      return nil, canceled
   end
   return result.result
end

function Command.wear(player)
   return EquipmentMenu:new(player):query()
end

local function feats_surrounding(player, field)
   return Pos.iter_surrounding(player.x, player.y):flatmap(Feat.at):filter(function(f) return f:calc(field) end)
end

function Command.close(player)
   local f = feats_surrounding(player, "can_close"):nth(1)
   if f then
      if Chara.at(f.x, f.y) then
         Gui.mes("action.close.blocked")
      else
         f:emit("elona_sys.on_feat_close", {chara=player})
      end
   end
end

local function feats_under(player, field)
   return Feat.at(player.x, player.y, player:current_map()):filter(function(f) return f:calc(field) end)
end

function Command.search(player)
   -- >>>>>>>> shade2/action.hsp:1482 *act_search ...
   local map = player:current_map()

   Gui.mes_duplicate()
   Gui.mes("action.search.execute")
   -- <<<<<<<< shade2/action.hsp:1483 	msgDup++:txt lang("周囲を注意深く調べた。","You search the s ..

   for j = 0, 10 do
      local y = player.y + j - 5
      if not (y < 0 or y >= map:height()) then
         for i = 0, 10 do
            local x = player.x + i - 5
            if not (x < 0 or x >= map:width()) then
               for _, f in Feat.at(x, y, map) do
                  f:emit("elona_sys.on_feat_search_from_distance", {chara=player})
               end
            end
         end
      end
   end

   local f = feats_under(player, "can_search"):nth(1)
   if f then
      local result = f:emit("elona_sys.on_feat_search", {chara=player}, "player_turn_query")
      return result or "player_turn_query"
   end

   player:emit("elona_sys.on_chara_search")

   return "turn_end"
end

function Command.help()
   local HelpMenuView = require("api.gui.menu.HelpMenuView")
   local SidebarMenu = require("api.gui.menu.SidebarMenu")

   local view = HelpMenuView:new()
   SidebarMenu:new(view:get_sections(), view):query()

   return "player_turn_query"
end

function Command.save_game()
   Save.save_game()
   return "player_turn_query"
end

function Command.load_game()
   Save.load_game()
   return "turn_begin"
end

function Command.quit_game()
   -- >>>>>>>> shade2/command.hsp:4351 *com_save ..
   Gui.mes_newline()
   Gui.mes("action.exit.prompt")
   local choices = {
      { text = "ui.yes", key = "y" },
      { text = "ui.no", key = "n" },
      { text = "action.exit.choices.game_setting", key = "c" },
      { text = "action.exit.choices.return_to_title", key = "t" },
   }
   local res = Input.prompt(choices)
   if res.index == 1 then
      local can_save = true -- TODO showroom
      if can_save then
         Save.save_game()
         Gui.mes("action.exit.saved")
         Gui.mes("action.exit.you_close_your_eyes")
         Input.query_more()
      end
      Gui.wait(300)
      return "quit"
   elseif res.index == 3 then
      Gui.play_sound("base.ok1")
      ConfigMenuWrapper:new():query()
   elseif res.index == 4 then
      Gui.play_sound("base.ok1")
      return "title_screen"
   end
   return "player_turn_query"
   -- <<<<<<<< shade2/command.hsp:4374 	goto *pc_turn ..
end

local CharacterInfoWrapper = require("api.gui.menu.CharacterInfoWrapper")

function Command.chara_info()
   CharacterInfoWrapper:new():query()
   return "player_turn_query"
end

local SpellsWrapper = require("api.gui.menu.SpellsWrapper")

local function handle_spells_result(result, chara)
   local command_type = result.type
   local skill_id = result._id

   if command_type == "spell" then
      local did_something = elona_Magic.cast_spell(skill_id, chara, false)
      if did_something then
         return "turn_end"
      end
      return "player_turn_query"
   elseif command_type == "skill" then
      local did_something = elona_Magic.do_action(skill_id, chara)
      if did_something then
         return "turn_end"
      end
      return "player_turn_query"
   end

   error("unknown spell result")
end

function Command.cast(player)
   local result, canceled = SpellsWrapper:new(1):query()
   if canceled then
      return "player_turn_query"
   end
   return handle_spells_result(result, player)
end

function Command.skill(player)
   local result, canceled = SpellsWrapper:new(2):query()
   if canceled then
      return "player_turn_query"
   end
   return handle_spells_result(result, player)
end

function Command.target(player)
   local x, y, can_see = Input.query_position()

   if x then
      -- >>>>>>>> shade2/command.hsp:323 			if (canSee=false)or(tAttb(map(tlocX,tlocY,0))&c ...
      local map = player:current_map()
      if not can_see or not Map.is_floor(x, y, map) then
         Gui.mes("action.which_direction.cannot_see_location")
      else
         Gui.play_sound("base.ok1")
         local chara = Chara.at(x, y, map)
         if chara and not chara:is_player() then
            player:set_target(chara)
            Gui.mes("action.look.target", chara)
         else
            player.target_location = { x = x, y = y }
            Gui.mes("action.look.target_ground")
         end
      end
      -- <<<<<<<< shade2/command.hsp:336 		return canSee ..
   end

   return "player_turn_query"
end

function Command.look(player)
   if Map.is_world_map() then
      Input.query_position()
   else
      local target, canceled = Input.query_target()
      if target then
         player:set_target(target)
         Gui.play_sound("base.ok1")
         Gui.mes("action.look.target", target)
      end
   end

   return "player_turn_query"
end

function Command.quick_menu(player)
   local action, canceled = QuickMenuPrompt:new():query()
   if canceled then
      return "player_turn_query"
   end

   local did_something, result = Gui.run_keybind_action(action, player)
   if did_something then
      return result
   end

   Log.warn("No keybind action found for '%s'", action)

   return "player_turn_query"
end

function Command.interact(player)
   -- >>>>>>>> shade2/command.hsp:1840 	txt lang("操作する対象の方向は？","Choose the direction of t ...
   Gui.mes("action.interact.choose")
   local dir = Input.query_direction(player)
   if dir == nil then
      Gui.mes("ui.invalid_target")
      Gui.update_screen()
      return "player_turn_query"
   end
   local x, y = Pos.add_direction(dir, player.x, player.y)
   local target = Chara.at(x, y)
   if target == nil then
      Gui.mes("ui.invalid_target")
      Gui.update_screen()
      return "player_turn_query"
   end

   local actions = {}
   target:emit("elona_sys.on_build_interact_actions", {player=player}, actions)

   if #actions > 0 then
   else
      Log.error("No interact actions returned from `elona_sys.on_build_interact_actions`.")
      Gui.mes("common.it_is_impossible")
      return "player_turn_query"
   end

   --[[
   actions = {
      { text = "action.interact.choices.talk", key = "a", callback = function(chara) ... end }
   }
   --]]

   local map = function(t)
      assert(type(t.text) == "string", "Action must have 'text' defined")
      assert(type(t.callback) == "function", "Action must have 'callback' defined")
      return { text = t.text or "", key = t.key or nil }
   end

   local items = fun.iter(actions):map(map):to_list()
   local result, canceled = Prompt:new(items):query()

   if canceled then
      Gui.update_screen()
      return "player_turn_query"
   end

   local choice = assert(actions[result.index])

   local params = {player=player}
   local turn_result = choice.callback(target, params) or "player_turn_query"

   return turn_result
   -- <<<<<<<< shade2/command.hsp:1867 	if (develop)or(gWizard):promptAdd lang("情報","Info ..
end

function Command.journal(player)
   local sort = function(a, b)
      return a.ordering < b.ordering
   end

   local render = function(page)
      return page.render()
   end

   local pages = data["base.journal_page"]:iter():into_sorted(sort):map(render):to_list()

   -- TODO icon bar wrapper
   JournalMenu:new(pages):query()

   return "player_turn_query"
end

return Command
