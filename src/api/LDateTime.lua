local LDateTime = class("LDateTime")

function LDateTime:init(year, month, day, hour, minute, second)
   self.year = year or 0
   self.month = month or 0
   self.day = day or 0
   self.hour = hour or 0
   self.minute = minute or 0
   self.second = second or 0
end

function LDateTime:hours()
   return self.hour
      + (self.day * 24)
      + (self.month * 24 * 30)
      + (self.year * 24 * 30 * 12)
end

return LDateTime
