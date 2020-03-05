--- @classmod DateTime

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


--- @tparam int hours
--- @treturn DateTime
function DateTime.from_hours(hours)
   local hour = hours % 24
   local day = math.floor(hours / 24) % 31
   local month = math.floor(hours / 24 / 30) % 12
   local year = math.floor(hours / 24 / 30 / 12)

   return DateTime:new(year, month, day, hour, 0, 0)
end

function DateTime:__tostring()
   return string.format("%d/%d/%d %02d:%02d:%02d", self.year, self.month, self.day, self.hour, self.minute, self.second)
end

return DateTime
