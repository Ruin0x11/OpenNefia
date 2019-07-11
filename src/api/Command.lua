local Action = require("api.Action")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Input = require("api.Input")
local Map = require("api.Map")
local Pos = require("api.Pos")
local EquipmentMenu = require("api.gui.menu.EquipmentMenu")

local save_store = require("internal.save_store")
local field = require("game.field")

--- Game logic intended for the player only.
local Command = {}

local travel_to_map = Event.define_hook("travel_to_map",
                                        "Hook when traveling to a new map.",
                                        {false, "No map configured"},
                                        function(result, default)
                                           if type(result) == "table" then
                                              return table.unpack(result)
                                           end

                                           return table.unpack(default)
end)

local player_move = Event.define_hook("player_move",
                                      "Hook when the player moves.",
                                      nil,
                                      "pos")

Event.register("base.hook_player_move", "Player scroll speed",
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
   local next_pos = player_move({chara=player}, {pos={x=x,y=y}})

   -- EVENT: before_player_move_check (player)
   -- dimmed
   -- drunk
   -- confusion
   -- mount
   -- overburdened

   -- At this point the next position is final.

   local on_cell = Chara.at(next_pos.x, next_pos.y)
   if on_cell then

      local result

      Event.trigger("base.on_player_bumped_into_chara", {player=player,chara=on_cell})

      local reaction = player:reaction_towards(on_cell)

      if reaction > 0 then
         if true then
            if player:swap_places(on_cell) then
               Gui.mes("You switch places with " .. on_cell.uid .. ".")
               Gui.set_scroll()
            end
         end
         return "turn_end"
      end

      -- TODO: relation as -1
      if reaction < 0 then
         player:set_target(on_cell)
         Action.melee(player, on_cell)
         Gui.set_scroll()
         return "turn_end"
      end

      return "turn_end"
   end

   if not Map.is_in_bounds(next_pos.x, next_pos.y) then
      -- Player is trying to move out of the map.

      Event.trigger("base.before_player_map_leave", {player=player})
      -- quest abandonment warning

      if Input.yes_no() then
         local success, map = travel_to_map()
         if not success then
            Gui.mes("Error loading map: " .. map)
         else
            Map.travel_to(map)
         end
      end

      return "player_turn_query"
   else
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
      Gui.mes("You grasp at air.")
      return "turn_end"
   end

   if #items == 1 then
      local item = items[1]
      Item.activate_shortcut(item, "inv_get", { chara = player })
      return "turn_end"
   end

   return Input.query_inventory(player, "inv_get")
end

function Command.drop(player)
   if player.inv:len() == 0 then
      Gui.mes("No items.")
      return "turn_end"
   end

   return Input.query_inventory(player, "inv_drop")
end

function Command.inventory(player)
   return Input.query_inventory(player, "inv_general")
end

function Command.wear(player)
   _p("wear",string.tostring_raw(EquipmentMenu))
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
         Gui.mes("Someone is in the way.")
      else
         Gui.mes(player.name .. " closes the " .. f.uid .. " ")
         f:calc("on_close", player)
      end
   end
end

function Command.open(player)
   for _, f in feats_surrounding(player, "can_open") do
      Gui.mes(player.name .. " opens the " .. f.uid .. " ")
      f:calc("on_open", player)
   end
end

function Command.activate(player)
   for _, f in feats_under(player, "can_activate") do
      Gui.mes(player.name .. " activates the " .. f.uid .. " ")
      f:calc("on_activate", player)
   end
end

function Command.save_game()
   local map = Map.current()
   assert(Map.save(map))

   do
      local global = save_store.for_mod("base")
      global.map = map.uid
      global.player = field.player
   end

   assert(save_store.save())

   Gui.mes("Game saved.")
   return "player_turn_query"
end

function Command.load_game()
   local success, map

   assert(save_store.load())

   local base = save_store.for_mod("base")
   local map_uid = base.map
   local player_uid = base.player

   success, map = Map.load(map_uid)
   assert(success)

   Map.set_map(map)
   Chara.set_player(player_uid)

   -- BUG: events registered with Event.register since the game has
   -- started will be left over when a save is reloaded.
   --
   -- TODO: should it be an error to register events outside
   -- on_game_initialize? then on_game_initialize becomes
   -- special-cased to avoid clearing it when a save is loaded. it
   -- might be better to restrict calling of Event.register to the mod
   -- startup stage.
   --
   -- an interface for creating global events that are cleaned up when
   -- a save is loaded could be used. or maybe that could become the
   -- main interface of Event anyway. a flag could be set if a global
   -- event is temporary, and it could be forced to true if mods
   -- aren't loading.
   --
   -- local global_events = require("internal.global.global_events")
   -- global_events:clear()

   Gui.mes_clear()
   Gui.mes("Game loaded.")

   Event.trigger("base.on_game_initialize")

   return "turn_begin"
end

return Command
