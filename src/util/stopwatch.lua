local socket = require("socket")

local stopwatch = class("stopwatch")

function stopwatch:init()
   self.time = socket.gettime()
end

function stopwatch:measure()
   local new = socket.gettime()
   local result = new - self.time
   self.time = new
   return result
end

function stopwatch:p(t)
   t = t or ""
   print(string.format("[%s] %04.04f", t, self:measure()))
end

return stopwatch
