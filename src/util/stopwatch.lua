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

return stopwatch
