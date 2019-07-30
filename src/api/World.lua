local Event = require("api.Event")
local save = require("internal.global.save")

local World = {}

local event_types = {
   second = 5,
   minute = 4,
   hour = 3,
   day = 2,
   month = 1,
   year = 0,
   none = -1,
}

function World.pass_time_in_seconds(seconds, events)
   events = events or event_types.second
   local date = save.base.date

   if events >= 5 then
      Event.trigger("base.on_second_passed", {seconds=seconds})
   end

   date.second = date.second + seconds
   if date.second >= 60 then
      save.base.play_turns = save.base.play_turns + 1

      local minutes_passed = math.floor(date.second / 60)

      date.minute = date.minute + minutes_passed

      if events >= 4 then
         Event.trigger("base.on_minute_passed", {minutes=minutes_passed})
      end

      date.second = date.second % 60

      if date.minute >= 60 then
         local hours_passed = math.floor(date.minute / 60)

         date.hour = date.hour + hours_passed
         date.minute = date.minute % 60

         if events >= 3 then
            Event.trigger("base.on_hour_passed", {hours=hours_passed})
         end

         if date.hour >= 24 then
            -- events before

            local days_passed = math.floor(date.hour / 24)
            save.base.play_days = save.base.play_days + days_passed
            date.day = date.day + days_passed
            date.hour = date.hour % 24

            if events >= 2 then
               Event.trigger("base.on_day_passed", {days=days_passed})
            end

            if date.day >= 31 then
               date.month = date.month + 1

               if events >= 1 then
                  Event.trigger("base.on_month_passed")
               end

               if date.month >= 13 then
                  date.year = date.year + 1
                  date.month = 1

                  if events >= 0 then
                     Event.trigger("base.on_year_passed")
                  end
               end
            end

            -- events after
         end
      end
   end
end

function World.date()
   return save.base.date
end

return World
