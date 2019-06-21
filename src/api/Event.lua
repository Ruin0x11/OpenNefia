local EventHolder = require("api.EventHolder")
local data = require("internal.data")

local Event = {}

local global_events = require ("internal.global.global_events")

local function check_event(event_id)
   if data["base.event"][event_id] == nil then
      error("Unknown event type \"" .. event_id .. "\"")
   end
end

function Event.register(event_id, name, cb, opts)
   check_event(event_id)
   global_events:register(event_id, name, cb, opts)
end

function Event.unregister(event_id, cb, opts)
   check_event(event_id)
   global_events:unregister(event_id, cb, opts)
end

function Event.trigger(event_id, args, opts)
   check_event(event_id)
   return global_events:trigger(event_id, args, opts)
end

function Event.add_observer(event_id, observer)
   check_event(event_id)
   return global_events:add_observer(event_id, observer)
end

function Event.remove_observer(event_id, observer)
   check_event(event_id)
   return global_events:remove_observer(event_id, observer)
end

function Event.list(event_id)
   return global_events:print(event_id)
end

return Event
