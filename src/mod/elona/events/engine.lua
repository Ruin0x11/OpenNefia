local Env = require("api.Env")
local Event = require("api.Event")
local Gui = require("api.Gui")
local I18N = require("api.I18N")

local time_warn_msecs = Env.get_time()
local hours_played = 0

local function init_time_warn()
   -- >>>>>>>> shade2/init.hsp:4342 	time_warn	=gmsec() ...
   time_warn_msecs = Env.get_time()
   -- <<<<<<<< shade2/init.hsp:4342 	time_warn	=gmsec() ..
end
Event.register("base.on_engine_init", "Initialize time warning message timestamp", init_time_warn)

local function show_time_warn_message(hours)
   -- >>>>>>>> shade2/etc.hsp:402 *time_warn_talk ...
   local mes = I18N.get_optional(("ui.time_warn_message._%d"):format(hours))
   -- <<<<<<<< shade2/etc.hsp:413  ..

   -- >>>>>>>> shade2/main.hsp:1023 		gosub *time_warn_talk:txtMore:txtEf coYellow:txt ...
   if mes then
      Gui.mes_c(mes, "Yellow")
   end
   -- <<<<<<<< shade2/main.hsp:1023 		gosub *time_warn_talk:txtMore:txtEf coYellow:txt ..
end

local function time_warn()
   -- >>>>>>>> shade2/main.hsp:1020 	if (gmsec()-time_warn)>3600{ ...
   local time = Env.get_time()
   if (time - time_warn_msecs) / 1000 > 3600 then -- every hour
      time_warn_msecs = time
      hours_played = hours_played + 1
      Gui.mes_c("action.playtime_report", "Yellow", hours_played)
      -- TODO there is a wishFilter flag that prevents the elochat wish log from
      -- being spammed by savescummers. It gets reset here.
      show_time_warn_message(hours_played)
   end
   -- <<<<<<<< shade2/main.hsp:1024 		} ..
end
Event.register("base.on_player_turn_query_frame", "Warn about elapsed time", time_warn)

local function show_startup_message()
   local version = "1.22"
   Gui.mes(("  Lafrontier presents Elona ver %s. Welcome traveler! "):format(version))
end
Event.register("base.on_game_initial_load", "Show startup message", show_startup_message)
