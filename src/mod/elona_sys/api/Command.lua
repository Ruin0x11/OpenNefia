local Action = require("api.Action")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Map = require("api.Map")
local MapArea = require("api.MapArea")
local Pos = require("api.Pos")
local EquipmentMenu = require("api.gui.menu.EquipmentMenu")
local Save = require("api.Save")

--- Game logic intended for the player only.
local Command = {}

local function travel_to_map_hook(source, params, result)
   local cur = Map.current()
   local success, map_result = MapArea.load_outer_map(cur)

   if not success then
      return {false, "Could not load outer map: " .. map_result}
   end

   local map = map_result.map
   map_result.map = nil

   save.base.player_pos_on_map_leave = { x = Chara.player().x, y = Chara.player().y }

   assert(Map.travel_to(map, map_result))

   return {true, "player_turn_query"}
end

local hook_travel_to_map = Event.define_hook("travel_to_map",
                                        "Hook when traveling to a new map.",
                                        { false, "Error running hook." },
                                        nil,
                                        travel_to_map_hook)

local hook_player_move = Event.define_hook("player_move",
                                      "Hook when the player moves.",
                                      nil,
                                      "pos")

Event.register("elona_sys.hook_player_move", "Player scroll speed",
               function(_, params, result)
                  local scroll = 10
                  local start_run_wait = 2
                  if Gui.key_held_frames() > start_run_wait then
                     scroll = 6
                  end

                  if Gui.player_is_running() then
                     scroll = 1
                  end

                  params.chara:mod("scroll", scroll, "set")

                  return result
               end)

function Command.move(player, x, y)
   if type(x) == "string" then
      x, y = Pos.add_direction(x, player.x, player.y)
   end

   -- Try to modify the final position.
   local next_pos = hook_player_move({chara=player}, {pos={x=x,y=y}})

   -- EVENT: before_player_move_check (player)
   -- dimmed
   -- drunk
   -- confusion
   -- mount
   -- overburdened

   -- At this point the next position is final.

   local on_cell = Chara.at(next_pos.x, next_pos.y)
   if on_cell then

      local result = player:emit("elona_sys.on_player_bumped_into_chara", {chara=on_cell}, "turn_end")

      return result
   end

   if not Map.is_in_bounds(next_pos.x, next_pos.y)
      and Map.current():calc("can_exit_from_edge")
   then
      -- Player is trying to move out of the map.

      Event.trigger("elona_sys.before_player_map_leave", {player=player})
      -- quest abandonment warning

      if Input.yes_no() then
         Gui.play_sound("base.exitmap1")
         Gui.update_screen()

         local success, result = table.unpack(hook_travel_to_map())

         if not success then
            Gui.report_error(result)
            return "player_turn_query"
         end

         return result
      end

      return "player_turn_query"
   else
      for _, obj in Map.current():objects_at_pos(next_pos.x, next_pos.y) do
         local result = obj:emit("elona_sys.on_bump_into", {chara=player}, nil)
         if result then return "turn_end" end
      end

      -- Run the general-purpose movement command. This will also
      -- handle blocked tiles.

      Action.move(player, next_pos.x, next_pos.y)
      Gui.set_scroll()
   end

   -- proc confusion text

   return "turn_end"
end

function Command.get(player)
   -- TODO: plants
   -- traps
   -- buildings
   -- snow

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

   return Input.query_inventory(player, "elona.inv_get")
end

function Command.drop(player)
   return Input.query_inventory(player, "elona.inv_drop")
end

function Command.inventory(player)
   return Input.query_inventory(player, "elona.inv_general")
end

function Command.wear(player)
   return EquipmentMenu:new(player):query()
end

local function feats_surrounding(player, field)
   local Feat = require("api.Feat")
   return Pos.iter_surrounding(player.x, player.y):flatmap(Feat.at):filter(function(f) return f:calc(field) end)
end

local function feats_under(player, field)
   local Feat = require("api.Feat")
   return Feat.at(player.x, player.y):filter(function(f) return f:calc(field) end)
end

function Command.close(player)
   for _, f in feats_surrounding(player, "can_close") do
      if Chara.at(f.x, f.y) then
         Gui.mes("action.close.blocked")
      else
         Gui.mes("action.close.execute", player)
         f:emit("elona_sys.on_feat_close", {chara=player})
      end
   end
end

function Command.search(player)
   local Feat = require("api.Feat")

   for j = 0, 10 do
      local y = player.y + j - 5
      if not (y < 0 or y >= player:current_map():height()) then
         for i = 0, 10 do
            local x = player.x + i - 5
            if not (x < 0 or x >= player:current_map():width()) then
               for _, f in Feat.at(x, y) do
                  f:emit("elona_sys.on_feat_search", {chara=player})
               end
            end
         end
      end
   end

   player:emit("elona_sys.on_search")
end

function Command.open(player)
   for _, f in feats_surrounding(player, "can_open") do
      Gui.mes(player.name .. " opens the " .. f.uid .. " ")
      f:emit("elona_sys.on_feat_open", {chara=player})
   end
end

local function activate(player, feat)
   Gui.mes(player.name .. " activates the " .. feat.uid .. " ")
   feat:emit("elona_sys.on_feat_activate", {chara=player})
end

function Command.enter_action(player)
   -- TODO iter objects on square, emit get_enter_action
   local f = feats_under(player, "can_activate"):nth(1)
   if f then
      activate(player, f)
      return "player_turn_query" -- TODO could differ per feat
   end

   -- HACK
   local is_world_map = Map.current().generated_with.params.id == "elona.north_tyris"

   if is_world_map then
      local params = {
         stood_x = player.x,
         stood_y = player.y,
      }
      local ok, map = Map.generate("elona.field", params)
      if not ok then
         Gui.report_error(map)
         return "player_turn_query"
      end

      Gui.play_sound("base.exitmap1")
      assert(Map.travel_to(map))

      return "turn_begin"
   end

   return "player_turn_query"
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
   Gui.mes_newline()
   Gui.mes("Do you want to save the game and exit? ")
   if Input.yes_no() then
      return "quit"
   end
   return "player_turn_query"
end

return Command
