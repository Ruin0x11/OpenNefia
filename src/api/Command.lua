local Input = require("api.Input")
local Chara = require("api.Chara")
local Pos = require("api.Pos")
local Map = require("api.Map")
local Action = require("api.Action")

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

   if Chara.at(next_pos.x, next_pos.y) then
      -- EVENT: on_player_bumped_into_character
      local result
      return result
   end

   if Map.can_access(next_pos.x, next_pos.y) then
      -- Can access spot, so try moving.
      -- Runs the general-purpose movement command.
      return Action.move(player, next_pos.x, next_pos.y)
   elseif not Map.is_in_bounds(next_pos.x, next_pos.y) then
      -- Player is trying to move out of the map.

      -- EVENT: before_player_map_leave
      -- quest abandonment warning

      Input.yes_no()
   else
      -- Player bumped into something solid. Is it a map object?
      -- EVENT: on_player_bumped_into_object
   end

   -- proc confusion text

   return "StopTurn"
end

return Command
