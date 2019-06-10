local Action = require("api.Action")
local Ai = require("api.Ai")
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

      local relation = Ai.relation_towards(player, on_cell)
      Event.trigger("base.on_player_bumped_into_chara", {player=player,on_cell=on_cell,relation=relation})

      if relation == "friendly"
         or relation == "citizen"
         or relation == "neutral"
      then
         if relation == "friendly" or relation == "citizen" then
            Chara.swap_places(player, on_cell)
         end
         return "turn_end"
      end

      -- TODO: relation as -1
      if relation == "enemy" then
         Ai.set_target(player, on_cell)
         return Action.melee(player, on_cell)
      end

      return "turn_end"
   end

   if Map.can_access(next_pos.x, next_pos.y) then
      -- Can access spot, so try moving.
      -- Runs the general-purpose movement command.
      return Action.move(player, next_pos.x, next_pos.y)
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

return Command
