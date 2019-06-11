local global = {}

function global.clear()
   local global_events = require("internal.global.global_events")
   global_events:clear()

   local data = require("internal.data")
   data:clear()
end

return global
