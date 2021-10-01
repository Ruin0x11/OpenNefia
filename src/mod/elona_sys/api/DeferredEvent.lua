local global = require("mod.elona_sys.internal.global")

local DeferredEvent = {}

function DeferredEvent.add(cb, priority)
   assert(type(cb) == "function")
   priority = priority or 100000
   global.deferred_events:insert(priority, cb)
end

function DeferredEvent.clear()
   global.deferred_events:clear()
end

function DeferredEvent.is_pending()
   return global.deferred_events:length() > 0
end

return DeferredEvent
