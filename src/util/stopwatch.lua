local internal = require("internal")

local stopwatch = {}
local stopwatch_mt = { __index = stopwatch }

function stopwatch:new()
   local s = {
      time = internal.get_timestamp()
   }
   setmetatable(s, stopwatch_mt)
   return s
end

function stopwatch:measure()
   local new = internal.get_timestamp()
   local result = new - self.time
   self.time = new
   return result
end

return stopwatch
