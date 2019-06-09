local EventHolder = require("api.EventHolder")

local Event = {}

local global_events = EventHolder:new()

function Event.register(event_id, name, cb, opts)
   global_events:register(event_id, name, cb, opts)
end

function Event.unregister(event_id, cb, opts)
   global_events:unregister(event_id, cb, opts)
end

function Event.trigger(event_id, args, opts)
   return global_events:trigger(event_id, args, opts)
end

return Event
