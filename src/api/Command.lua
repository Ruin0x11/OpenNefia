local Action = require("api.Action")
local Gui = require("api.Gui")
local Ai = require("api.Ai")
local Item = require("api.Item")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Input = require("api.Input")
local Map = require("api.Map")
local Pos = require("api.Pos")

--- Game logic intended for the player only.
local Command = {}

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
            end
         end
         return "turn_end"
      end

      -- TODO: relation as -1
      if reaction < 0 then
         player:set_target(on_cell)
         Action.melee(player, on_cell)
         return "turn_end"
      end

      return "turn_end"
   end

   if Map.can_access(next_pos.x, next_pos.y) then
      -- Can access spot, so try moving.
      -- Runs the general-purpose movement command.
      Action.move(player, next_pos.x, next_pos.y)
      return "turn_end"
   elseif not Map.is_in_bounds(next_pos.x, next_pos.y) then
      -- Player is trying to move out of the map.

      Event.trigger("base.before_player_map_leave", {player=player})
      -- quest abandonment warning

      Input.yes_no()
   else
      -- Player bumped into something solid. Is it a map object?
      Event.trigger("base.on_player_bumped_into_object", {player=player})
   end

   -- proc confusion text

   return "turn_end"
end

function Command.get(player)
   -- TODO: plants
   -- traps
   -- buildings
   -- snow

   local items = Item.at(player.x, player.y)
   if #items == 0 then
      Gui.mes("You grasp at air.")
      return "turn_end"
   end

   if #items > 1 then
      Gui.mes("More than one item.")
      return "turn_end"
   end

   local item = items[1]

   if item.ownership ~= "none" then
      Gui.mes("It's not yours.")
      return "turn_end"
   end

   return Action.get(player, item)
end

function Command.inventory(player)
   Input.query_inventory(player, true)

   return "player_turn_query"
end

return Command
