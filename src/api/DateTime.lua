--- @module DateTime

local DateTime = class.class("DateTime")

--- @function DateTime:new
--- @tparam[opt] int year
--- @tparam[opt] int month
--- @tparam[opt] int day
--- @tparam[opt] int hour
--- @tparam[opt] int minute
--- @tparam[opt] int second
function DateTime:init(year, month, day, hour, minute, second)
   self.year = year or 0
   self.month = month or 0
   self.day = day or 0
   self.hour = hour or 0
   self.minute = minute or 0
   self.second = second or 0
end

--- Returns the date in hours. Used in various places for time
--- tracking purposes.
---
--- @treturn int
function DateTime:hours()
   return self.hour
      + self.day * 24
      + self.month * 24 * 30
      + self.year * 24 * 30 * 12
end

return DateTime
