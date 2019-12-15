local Chara = require("api.Chara")
local Event = require("api.Event")
local Save = require("api.Save")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Map = require("api.Map")
local World = require("api.World")
local Log = require("api.Log")
local draw = require("internal.draw")
local field = require("game.field")
local data = require("internal.data")
local save = require("internal.global.save")

local DeathMenu = require("api.gui.menu.DeathMenu")

local field_logic = {}

function field_logic.setup_new_game(player)
   local scenario = data["base.scenario"]:ensure(save.base.scenario)

   Chara.set_player(player)
   scenario:on_game_start(player)

   save.base.home_map_uid = save.base.home_map_uid or Map.current().uid
   assert(save.base.home_map_uid)

   Event.trigger("base.on_new_game")
end

function field_logic.quickstart()
   field:init_global_data()

   save.base.scenario = "elona.elona"

   local me = Chara.create("content.player", nil, nil, {ownerless=true})
   field_logic.setup_new_game(me)
end

function field_logic.setup()
   -- This function gets called again if field_logic.query() throws an
   -- error, so don't rerun base.on_game_initialize.
   if not field.repl then
      field:setup_repl()
   end
   if not field.is_active then
      Event.trigger("base.on_game_initialize")
   end
end

function field_logic.update_chara_time_this_turn(time_this_turn)
   for _, chara in Chara.iter() do
      if Chara.is_alive(chara) then
         -- Ensure all characters (including the player) have a
         -- turn cost at least as much as the player's starting
         -- turn cost, since the player always goes first at the
         -- beginning of a turn.
         chara.time_this_turn = chara.time_this_turn + chara:emit("base.on_calc_speed") * time_this_turn
      end
   end
end

local player_finished_turn = false
local chara_iter = nil
local chara_iter_state = nil
local chara_iter_index = 0

function field_logic.turn_begin()
   local turn_result = Event.trigger("base.on_turn_begin", {}, nil)
   if turn_result then
      -- return turn_result
   end

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

   chara_iter, chara_iter_state, chara_iter_index = Chara.iter()

   local speed = player:emit("base.on_calc_speed")

   -- All characters will start with at least this much time during
   -- this turn.
   local starting_turn_time = (field:turn_cost() - player.time_this_turn) / speed + 1

   -- TODO: world map continuous action

   local update_time_this_turn = true
   if update_time_this_turn then
      field_logic.update_chara_time_this_turn(starting_turn_time)
   end

   World.pass_time_in_seconds(starting_turn_time / 5 + 1)

   field:get_message_window():new_turn()

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
   local chara
   local going = true
   local any_moved = true

   while going do
      repeat
         chara_iter_index, chara = chara_iter(chara_iter_state, chara_iter_index)

         if chara ~= nil and chara.time_this_turn >= field:turn_cost() then
            found = chara
            any_moved = true
         end
      until found ~= nil or chara_iter_index == nil

      if found or any_moved == false then
         going = false
      end

      if chara_iter_index == nil then
         any_moved = false
         chara_iter, chara_iter_state, chara_iter_index = Chara.iter()
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

   chara:emit("base.before_chara_turn_start")

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

   if chara:is_player() and not Chara.is_alive(chara) then
      return "player_died", chara
   end

   -- proc mef
   -- proc buff

   local result = chara:emit("base.on_chara_pass_turn", {}, {blocked=false})
   if result.blocked then
      return result.turn_result or "turn_end", chara
   end

   -- RETURN: proc drunk
   -- proc stopping activity if damaged
   -- proc turn % 25

   if chara:has_activity() then
      chara:_proc_activity_interrupted()
   end

   if chara.turns_alive % 25 == 0 then
      -- TODO curse_power
      -- TODO pregnant
   end

   -- RETURN: proc activity
   -- proc refresh if transferred

   if chara:has_activity() then
      local turn_result = chara:pass_activity_turn()
      if turn_result then
         return turn_result
      end
   end

   if Chara.is_alive(chara) then
      if chara:is_player() then
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

local dt = 0

function field_logic.player_turn_query()
   local result
   local going = true

   local player = Chara.player()
   if not Chara.is_alive(player) then
      return "player_died"
   end

   Gui.update_screen(nil, dt)

   while going do
      local ran, turn_result = field:run_actions(dt, player)
      field:update(dt)

      if field.repl then
         local success, turn_result = field.repl:execute_all_deferred()
         if success and turn_result then
            result = turn_result
            going = false
            break
         end
      end

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
   local Ai = require("api.Ai")
   Ai.run(npc.ai, npc)

   return "turn_end", npc
end

function field_logic.turn_end(chara)
   if not Chara.is_alive(chara) then
      return "pass_turns"
   end

   local result = chara:emit("base.on_chara_turn_end", {}, {regeneration=true})
   local regen = result.regeneration

   if Chara.is_player(chara) then
      -- hunger
      -- sleep
   else
      -- quest delivery flag
   end

   -- party time emoicon

   if regen then
      chara:emit("base.on_regenerate")
   end

   -- proc timestop

   return "pass_turns"
end

local function revive_player()
   local player = Chara.player()
   assert(player:revive())

   local success, map = Map.load(save.base.home_map_uid)
   assert(success, map)
   Map.travel_to(map)
end

function field_logic.player_died()
   Gui.play_sound("base.dead1")
   Gui.mes("misc.death.good_bye")
   Gui.mes("misc.death.you_leave_dying_message")
   Gui.update_screen()

   Gui.mes("Last words? ")
   local last_words = Input.query_text(16, true)
   if last_words == nil then
      last_words = I18N.get("system.last_words")
   else
      last_words = I18N.get("misc.death.dying_message", last_words)
   end

   local result, canceled = DeathMenu:new({{ last_words = last_words, death_cause = "death cause", image = Chara.player():copy_image() }}):query()
   if canceled or result.index == 1 then
      revive_player()
      return "turn_begin"
   end

   return "quit"
end

function field_logic.run_one_event(event, target_chara)
   local cb = nil

   if Chara.player() == nil then
      -- Something went wrong; at least boot the game back to the
      -- title so it doesn't have to be restarted.
      Log.error("Player is nil, returning to title.")
      return false
   end

   -- Wait for draw callbacks if necessary.
   while field:update_draw_callbacks(dt) do
      dt = coroutine.yield()
   end

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
      return false
   end

   if type(cb) ~= "function" then
      error("Unknown turn event " .. inspect(event))
   end

   local success
   success, event, target_chara = xpcall(function() return cb(target_chara) end, debug.traceback)

   if not success then
      -- pass the error up to the main loop so the handler can run
      coroutine.yield(event)

      event = "player_turn_query"
      target_chara = nil
   end

   return true, event, target_chara
end

function field_logic.query()
   Log.info("Entered main loop.")

   field_logic.setup()

   local event = "turn_begin"
   local going = true
   local target_chara

   field.is_active = true

   draw.push_layer(field.hud, 1000000)
   draw.push_layer(field)

   Gui.update_screen()

   while going do
      going, event, target_chara = field_logic.run_one_event(event, target_chara)
   end

   draw.pop_layer()
   draw.pop_layer()

   field.map = nil
   field.is_active = false

   return "title"
end

return field_logic
