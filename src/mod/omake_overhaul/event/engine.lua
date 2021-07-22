local Event = require("api.Event")
local Chara = require("api.Chara")
local Gui = require("api.Gui")

local function show_startup_message()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:79242 	if (firstturn == 1) { ...
   local player = Chara.player()
   if not player then
      return
   end

   if player:calc("can_catch_god_signals") then
      Gui.mes_c("omake_overhaul:engine.you_really_started_that_thing", "Yellow")
   end
   -- <<<<<<<< oomSEST/src/southtyris.hsp:79249 	} ..
end
Event.register("base.on_game_initial_load", '"You really started that thing?"', show_startup_message, { priority = 200000 })
