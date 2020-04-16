local Chara = require("api.Chara")
local Event = require("api.Event")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Map = require("api.Map")

local Pathing = require("mod.autoexplore.api.Pathing")
local Util = require("mod.autoexplore.api.Util")

local pathing = nil
local autoexplore = false
local attacked = false
local cancelable = false

--
-- Autoexplore control API
--

local Autoexplore = {}

function Autoexplore.start(dest, waypoint)
   pathing = Pathing:new(dest, waypoint)
   attacked = false
   autoexplore = true
   cancelable = false
end

function Autoexplore.stop()
   pathing = nil
   attacked = false
   autoexplore = false
   cancelable = false
end


--
-- Main macro handling
--

local function is_any_key_pressed()
   -- TODO
   return false
end

local function check_cancel()
   if is_any_key_pressed() then
      if cancelable then
         Gui.mes("autoexplore.key_pressed", I18N.get("autoexplore." .. pathing.type .. ".name"))
         Autoexplore.stop()
         return
      end
   else
      cancelable = true
   end
end

local function iter_fov()
   local map = Map.current()
   return map:iter_tiles():filter(function(x, y) return map:is_in_fov(x, y) end)
end

-- Called when the player's turn begins. If autoexplore is active, it
-- inputs the appropriate movement action for the player
-- automatically.
local function step_autoexplore()
   if not autoexplore then
      return
   end

   if Chara.player():has_effect("elona.confusion") then
      Gui.mes("autoexplore.confused", I18N.get("autoexplore." .. pathing.type .. ".name"))
      Autoexplore.stop()
      return
   end

   for _, x, y in iter_fov() do
      local chara = Chara.at(x, y)
      if chara and chara:reaction_towards(Chara.player()) < 0 then
         Gui.mes("autoexplore.enemy_sighted", chara, I18N.get("autoexplore." .. pathing.type .. ".name"))
         Autoexplore.stop()
         return
      end
   end

   if attacked then
      Autoexplore.stop()
      return
   end

   local next_action = pathing:get_action()

   if next_action then
      if check_cancel() then
         return
      end

      Input.enqueue_macro(next_action)
      -- Input.ignore_keywait()
   else
      Autoexplore.stop()
   end
end


--
-- Autoexplore functionality
--

function Autoexplore.do_travel(player)
   Gui.mes("autoexplore.travel.prompt")
   local dest_x, dest_y = Input.query_position()
   if dest_x then
      if dest_x == player.x and dest_y == player.y then
         Gui.mes("autoexplore.travel.already_there")
         return "player_turn_query"
      end

      -- TODO remove position-based code
      local dest = { x = dest_x, y = dest_y }

      if not Util.is_safe_to_travel(dest) then
         Pathing.print_halt_reason(dest)
         return "player_turn_query"
      end

      Gui.mes_newline()
      Gui.mes("autoexplore.travel.start")
      Autoexplore.start(dest, nil)
      return "player_turn_query"
   end

   return "player_turn_query"
end

function Autoexplore.do_autoexplore(player)
   if Map.is_world_map() then
      Gui.mes("autoexplore.explore.cannot_in_overworld")
      Autoexplore.stop()
      return "player_turn_query"
   end

   Gui.mes_newline()
   Gui.mes("autoexplore.explore.start")
   Autoexplore.start(nil, nil)
   return "player_turn_query"
end


--
-- Event callback functions
--

local function on_damaged(_, params)
   if Chara.is_player(params.chara) then
      attacked = true
   end
end
Event.register("base.after_damage_hp", "Stop autoexplore on damage", on_damaged)

local function on_killed(chara)
   if Chara.is_player(chara) then
      Autoexplore.stop()
   end
end
Event.register("base.on_chara_killed", "Stop autoexplore on death", on_killed)

local function on_map_enter()
   Autoexplore.stop()
end
Event.register("base.on_map_enter", "Stop autoexplore on map enter", on_map_enter)


-- TODO: It would be ideal to integrate this with the continuous
-- action/activity system, to allow things like player damage to be
-- consistently handled. It makes logical sense since control is taken
-- away from the player.
Event.register("base.on_player_turn", "Enqueue action from autoexplore", step_autoexplore)

-- Event.register(Event.EventKind.MenuEntered, Macro.clear_queue)

return Autoexplore