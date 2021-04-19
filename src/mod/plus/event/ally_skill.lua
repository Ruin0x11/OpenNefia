local SleepEvent = require("mod.plus.api.SleepEvent")
local Event = require("api.Event")

local function proc_ally_sleep_events()
   local hour = save.base.date.hour

   -- >>>>>>>> custom-1.90.4/source-utf8.hsp:263311 	breakfast = 0 ...
   if hour >= 4 and hour <= 9 then
      SleepEvent.breakfast()
   end
   if hour >= 4 and hour <= 12 then
      SleepEvent.handmade_gift()
   end
   if hour >= 4 and hour <= 12 then
      SleepEvent.handknitted_gift()
   end
   -- <<<<<<<< custom-1.90.4/source-utf8.hsp:263324 	breakfast = 0 ..
end
Event.register("elona.on_sleep_finish", "Ally breakfast/handmade gifts/handknitted gifts", proc_ally_sleep_events)
