local internal = require("internal")

local stopwatch = class("stopwatch")

function stopwatch:init()
   self.time = internal.get_timestamp()
end

function stopwatch:measure()
   local new = internal.get_timestamp()
   local result = new - self.time
   self.time = new
   return result
end

function stopwatch:p(t)
   t = t or ""
   print(string.format("[%s] %02.02f", t, self:measure()))
end

return stopwatch
