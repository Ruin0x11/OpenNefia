local Chara = require("api.Chara")
local Command = require("api.Command")
local Input = require("api.Input")
local Map = require("api.Map")
local Gui = require("api.Gui")
local World = require("api.World")
local draw = require("internal.draw")
local field = require("game.field")
local map = require("internal.map")

local field_logic = {}

function field_logic.setup()
   field:set_map(map.create(20, 20))

   do
      local me = Chara.create("base.player", 10, 10)
      Chara.set_player(me)
   end

   -- TODO: make bind_keys have callbacks that pass in player as
   -- argument
   field:bind_keys {
      a = function(me)
         print("do")
      end,
      up = function(me)
         local p = Chara.player()
         Command.move(p, "North")
      end,
      down = function(me)
         local p = Chara.player()
         Command.move(p, "South")
      end,
      left = function(me)
         local p = Chara.player()
         Command.move(p, "East")
      end,
      right = function(me)
         local p = Chara.player()
         Command.move(p, "West")
      end,
      ["."] = function(me)
         World.pass_time_in_seconds(600)
      end,
      ["`"] = function(me)
         require("api.gui.menu.Repl"):new({}):query()
      end,
      escape = function(me)
         if Input.yes_no() then
            going = false
         end
      end,
      ["return"] = function()
         print(require("api.gui.TextPrompt"):new(16):query())
      end,
   }
end

local function calc_speed(chara)
   return Chara.stat(chara, "base.speed")
end

function field_logic.update_chara_time_this_turn(time_this_turn)
   for _, chara in Map.iter_charas() do
      if Chara.is_alive(chara) then
         -- Ensure all characters (including the player) have a
         -- turn cost at least as much as the player's starting
         -- turn cost, since the player always goes first at the
         -- beginning of a turn.
         local speed = calc_speed(chara)
         if speed < 10 then
            speed = 10
         end
         chara.time_this_turn = chara.time_this_turn + speed * time_this_turn
      end
   end
end

local player_finished_turn = false
local uids_this_turn = table.set {}

function field_logic.turn_begin()
   local player = Chara.player()

   if not Chara.is_alive(player) then
      -- NOTE: should be an internal event, separate from ones that
      -- event callbacks may return.
      return "player_died"
   end

   -- In Elona, the player always goes first at the start of each
   -- turn, followed by allies, adventurers, then others. This was
   -- previously accomplished by simply iterating the cdata[] array by
   -- increasing index, since the player was always index 0, allies
   -- index 1-15, adventurers 15-56, and so on.
   player_finished_turn = false

   uids_this_turn = table.set {}

   local speed = calc_speed(player)
   if speed < 10 then
      speed = 10
   end

   -- All characters will start with at least this much time during
   -- this turn.
   local starting_turn_time = (field:turn_cost() - player.time_this_turn) / speed + 1

   -- TODO: world map continuous action

   local update_time_this_turn = true
   if update_time_this_turn then
      field_logic.update_chara_time_this_turn(starting_turn_time)
   end

   World.pass_time_in_seconds(starting_turn_time / 5 + 1)

   -- TODO: message new turn

   return "pass_turns"
end

function field_logic.determine_turn()
   local player = Chara.player()
   assert(player ~= nil)

   -- TODO: check if player can go first, then allies, then others.
   if not player_finished_turn then
      player_finished_turn = true
      return player
   end

   -- HACK: use a better way that also orders allies first
   local found = nil
   for _, c in Map.iter_charas() do
      if not uids_this_turn[c.uid] then
         if Chara.is_alive(c) then
            if c.time_this_turn >= field:turn_cost() then
               found = c
               break
            end
         end
      end
   end

   return found
end

function field_logic.pass_turns()
   local chara = field_logic.determine_turn()

   if chara == nil then
      -- Start a new turn.
      return "turn_begin"
   end

   uids_this_turn[chara.uid] = true

   chara.time_this_turn = chara.time_this_turn - field:turn_cost()

   chara.turns_alive = chara.turns_alive + 1

   -- EVENT: before_chara_begin_turn
   -- emotion icon
   -- wet if outdoors and rain

   -- BUILTIN: gain level

   -- if Chara.is_player(chara) then
      -- actually means beginning of all turns.

      -- refresh speed?
      -- prevent escape
      -- RETURN: potentially exit map here
      -- proc map events
      -- ether disease
   -- end

   if Chara.is_player(chara) and not Chara.is_alive(chara) then
      return "player_died"
   end

   -- proc mef
   -- proc buff
   -- RETURN: proc status effect
   -- RETURN: proc drunk
   -- proc stopping activity if damaged
   -- proc turn % 25

   -- RETURN: proc activity
   -- proc refresh if transferred

   if Chara.is_alive(chara) then
      if Chara.is_player(chara) then
         return "player_turn"
      else
         return "npc_turn"
      end
   end

   return "pass_turns"
end

function field_logic.player_turn()
   return "player_turn_query"
end

function field_logic.player_turn_query()
   local result
   local going = true
   local dt = 0

   local player = Chara.player()
   assert(Chara.is_alive(player))

   while going do
      local ran, turn_result = field:run_actions(dt, player)
      field:update(dt)

      if ran == true then
         result = turn_result or "turn_end"
         going = false
         break
      end

      dt = coroutine.yield()
   end

   -- TODO: convert public to internal event

   return result
end

function field_logic.npc_turn()
   return "turn_end"
end

function field_logic.turn_end()
   -- EVENT: on_turn_end

   -- proc timestop

   return "pass_turns"
end

function field_logic.query()
   field_logic.setup()

   local event = "turn_begin"
   local going = true

   field.is_active = true

   draw.push_layer(field)

   while going do
      local cb = nil

      Gui.update_screen()

      if event == "turn_begin" then
         cb = field_logic.turn_begin
      elseif event == "turn_end" then
         cb = field_logic.turn_end
      elseif event == "player_died" then
         cb = field_logic.player_died
      elseif event == "player_turn" then
         cb = field_logic.player_turn
      elseif event == "player_turn_query" then
         cb = field_logic.player_turn_query
      elseif event == "npc_turn" then
         cb = field_logic.npc_turn
      elseif event == "pass_turns" then
         cb = field_logic.pass_turns
      end

      if type(cb) ~= "function" then
         error("Unknown turn event " .. tostring(event))
      end

      event = cb()
   end

   draw.pop_layer()

   field.is_active = false
end

return field_logic
