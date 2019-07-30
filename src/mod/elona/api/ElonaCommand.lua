local Pos = require("api.Pos")
local Input = require("api.Input")
local Gui = require("api.Gui")
local ElonaAction = require("mod.elona.api.ElonaAction")

local ElonaCommand = {}

function ElonaCommand.bash(player)
   Gui.mes("Which direction?")
   local dir = Input.query_direction()

   if not dir then
      Gui.mes("Okay, then.")
      return "player_turn_query"
   end

   local result = ElonaAction.bash(player, Pos.add_direction(dir, player.x, player.y))

   if not result then
      return "player_turn_query"
   end

   return "turn_end"
end

return ElonaCommand
