local Chara = require("api.Chara")
local Command = require("api.Command")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Map = require("api.Map")
local StatusEffect = require("api.StatusEffect")
local World = require("api.World")
local draw = require("internal.draw")
local field = require("game.field")
local map = require("internal.map")

local field_logic = {}

function field_logic.setup()
   field:set_map(Map.generate("base.test", {}))

   do
      local me = Chara.create("base.player", 10, 10)
      Chara.set_player(me)
      StatusEffect.apply(me, "base.gravity", 10)
   end

   for i=1,4 do
      local a = Chara.create("base.ally", i+8, 3)
      Chara.recruit_as_ally(a)
   end

   for i=1,2 do
      for j=1,1 do
         local i = Chara.create("base.enemy", i+8, j+11)
      end
   end

   -- TODO: make bind_keys have callbacks that pass in player as
   -- argument
   field:bind_keys {
      a = function(me)
         print("do")
      end,
      up = function(me)
         return Command.move(me, "North")
      end,
      down = function(me)
         return Command.move(me, "South")
      end,
      left = function(me)
         return Command.move(me, "East")
      end,
      right = function(me)
         return Command.move(me, "West")
      end,
      ["."] = function(me)
         World.pass_time_in_seconds(600)
         return "turn_end"
      end,
      ["`"] = function(me)
         field:query_repl()
         return "player_turn_query"
      end,
      escape = function(me)
         if Input.yes_no() then
            return "quit"
         end
         return "player_turn_query"
      end,
      ["return"] = function()
         print(require("api.gui.TextPrompt"):new(16):query())
         return "player_turn_query"
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
local chara_iter = nil
local chara_iter_state = nil
local chara_iter_index = 0

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

   chara_iter, chara_iter_state, chara_iter_index = Map.iter_charas()

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

   Gui.mes_new_turn()

   return "pass_turns"
end

local sw = require("util.stopwatch"):new()

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
   local chara
   repeat
      chara_iter_index, chara = chara_iter(chara_iter_state, chara_iter_index)

      if chara ~= nil and chara.time_this_turn >= field:turn_cost() then
         chara.time_this_turn = chara.time_this_turn - field:turn_cost()
         found = chara
      end
   until found ~= nil or chara_iter_index == nil

   return found
end

function field_logic.pass_turns()
   local chara = field_logic.determine_turn()

   if chara == nil then
      -- Start a new turn.
      return "turn_begin"
   end

   Event.trigger("base.before_chara_turn_start", {chara=chara})

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
      return "player_died", chara
   end

   -- proc mef
   -- proc buff

   local result = StatusEffect.proc_turn_begin(chara)
   if result ~= nil then
      return result, chara
   end

   -- RETURN: proc drunk
   -- proc stopping activity if damaged
   -- proc turn % 25

   -- RETURN: proc activity
   -- proc refresh if transferred

   if Chara.is_alive(chara) then
      if Chara.is_player(chara) then
         return "player_turn", chara
      else
         return "npc_turn", chara
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

   Gui.update_screen()

   while going do
      local ran, turn_result = field:run_actions(dt, player)
      field:update(dt)

      if ran == true then
         result = turn_result or "player_turn_query"
         going = false
         break
      end

      dt = coroutine.yield()
   end

   -- TODO: convert public to internal event

   return result, player
end

function field_logic.npc_turn(npc)
   local npc_ai = require("game.npc_ai")
   local action = npc_ai.decide_action(npc)
   assert(action ~= nil)

   if action == "turn_end" then
      return "turn_end", npc
   end

   local result = npc_ai.handle_ai_action(npc, action)
   assert(result ~= nil)

   return result, npc
end

function field_logic.turn_end(chara)
   if not Chara.is_alive(chara) then
      return "pass_turns"
   end

   Event.trigger("base.on_chara_turn_end", {chara=chara})

   local regen = StatusEffect.proc_turn_end(chara)
   if Chara.is_player(chara) then
      -- hunger
      -- sleep
   else
      -- quest delivery flag
   end

   -- party time emoicon

   if regen then
      Chara.regen_hp_mp(chara)
   end

   -- proc timestop

   return "pass_turns"
end

function field_logic.player_died()
   -- Gui.mes_clear()
   Gui.mes("You died. ")
   Gui.update_screen()

   Gui.mes("Last words? ")
   local last_words = Input.prompt_text(16, true)
   if last_words == nil then
      last_words = "Scut!"
   end

   Gui.mes("Bury? ")
   local bury = Input.yes_no()
   if bury then
      return "quit"
   end

   return "quit"
end

function field_logic.query()
   field_logic.setup()

   local event = "turn_begin"
   local going = true
   local target_chara

   field.is_active = true

   draw.push_layer(field)

   while going do
      local cb = nil

      if field.map_changed == true then
         event = "turn_begin"
         field.map_changed = false
      end

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
      elseif event == "quit" then
         break
      end

      if type(cb) ~= "function" then
         error("Unknown turn event " .. tostring(event))
      end

      event, target_chara = cb(target_chara)
   end

   draw.pop_layer()

   field.is_active = false

   return "title"
end

return field_logic
