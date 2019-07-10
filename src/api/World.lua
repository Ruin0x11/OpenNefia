local save = require("internal.global.save")

local World = {}

function World.pass_time_in_seconds(seconds)
   local date = save.date

   -- EVENT: on_second_passed

   date.second = date.second + seconds
   if date.second >= 60 then
      save.play_turns = save.play_turns + 1

      local minutes_passed = math.floor(date.second / 60)

      date.minute = date.minute + minutes_passed

      -- EVENT: on_minute_passed

      date.second = date.second % 60

      if date.minute >= 60 then
         local hours_passed = math.floor(date.minute / 60)

         date.hour = date.hour + hours_passed
         date.minute = date.minute % 60
         -- EVENT: on_hour_passed

         if date.hour >= 24 then
            -- events before

            local days_passed = math.floor(date.hour / 24)
            save.play_days = save.play_days + days_passed
            date.day = date.day + days_passed
            date.hour = date.hour % 24
            -- EVENT: on_day_passed

            if date.day >= 31 then
               date.month = date.month + 1
               -- EVENT: on_month_passed

               if date.month >= 13 then
                  date.year = date.year + 1
                  date.month = 1
                  -- EVENT: on_year_passed
               end
            end

            -- events after
         end
      end
   end
end

return World
