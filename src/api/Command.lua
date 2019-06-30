local Action = require("api.Action")
local Gui = require("api.Gui")
local Ai = require("api.Ai")
local Item = require("api.Item")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Input = require("api.Input")
local Map = require("api.Map")
local Pos = require("api.Pos")
local EquipmentMenu = require("api.gui.menu.EquipmentMenu")

local field = require("game.field")

--- Game logic intended for the player only.
local Command = {}

local travel_to_map = Event.hook("travel_to_map",
                                 "Hook when traveling to a new map.",
                                 {nil, "No map configured"},
                                 function(result, default)
                                    if type(result) == "table" then
                                       return table.unpack(result)
                                    end

                                    return table.unpack(default)
                                 end)

function Command.move(player, x, y)
   if type(x) == "string" then
      x, y = Pos.add_direction(x, player.x, player.y)
   end
   local next_pos = { x = x, y = y }

   -- Try to modify the final position.

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
         local map, err = travel_to_map()
         if not map then
            Gui.mes("Error loading map: " .. err)
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
      return "turn_end"
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

local function get_feats(player, field)
   local Feat = require("api.Feat")
   return Pos.iter_surrounding(player.x, player.y):flatmap(Feat.at):filter(function(f) return f:calc(field) end)
end

function Command.close(player)
   for _, f in get_feats(player, "can_close") do
      if Chara.at(f.x, f.y) then
         Gui.mes("Someone is in the way.")
      else
         Gui.mes(player.name .. " closes the " .. f.uid .. " ")
         f:calc("on_close", player)
      end
   end
end

function Command.open(player)
   for _, f in get_feats(player, "can_open") do
      Gui.mes(player.name .. " opens the " .. f.uid .. " ")
      f:calc("on_open", player)
   end
end

function Command.activate(player)
   local Feat = require("api.Feat")
   for _, f in Feat.at(player.x, player.y):filter(function(f) return f:calc("can_activate") end) do
      Gui.mes(player.name .. " activates the " .. f.uid .. " ")
      f:calc("on_activate", player)
   end
end

return Command
