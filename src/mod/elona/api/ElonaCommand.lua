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

function ElonaCommand.do_eat(player, item)
   if player:calc("nutrition") > 10000 then
      Gui.mes("too bloated.")
      Gui.update_screen()
      return "player_turn_query"
   end

   local result = ElonaAction.eat(player, item)

   if not result then
      return "player_turn_query"
   end

   return "turn_end"
end

function ElonaCommand.eat(player)
   return Input.query_inventory(player, "inv_eat")
end

function ElonaCommand.do_dig(player, x, y)
   if player.stamina < 0 then
      Gui.mes("too exhausted")
      return false
   end

   player:start_activity("elona.dig_wall", {x = x, y = y})
   return true
end

function ElonaCommand.dig(player)
   Gui.mes("Which direction?")
   local dir = Input.query_direction()

   if not dir then
      Gui.mes("Okay, then.")
      return "player_turn_query"
   end

   local x, y = Pos.add_direction(dir, player.x, player.y)

   if x == player.x and y == player.y then
      Gui.mes("dig spot")
      return "player_turn_query"
   end

   -- Don't allow digging into water.
   local tile = player:current_map():tile(x, y)
   local can_dig = tile.is_solid and tile.is_opaque

   if not can_dig then
      Gui.mes("it is impossible.")
      return "player_turn_query"
   end

   Gui.update_screen()
   local result = ElonaCommand.do_dig(player, x, y)

   if not result then
      return "player_turn_query"
   end

   return "turn_end"
end

return ElonaCommand
