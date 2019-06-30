local Event = require("api.Event")
local EventHolder = require("api.EventHolder")

local IObserver = class.interface("IObserver")

function IObserver:init()
   self.events = EventHolder:new()
   self.global_events = EventHolder:new()
end

function IObserver:emit(event_id, params, result)
   return self.events:trigger(event_id, self, params, result)
end

function IObserver:trigger_global(event_id, params, result)
   return self.global_events:trigger(event_id, self, params, result)
end

local cache = {}

function IObserver:connect_self(event_id, name, cb, opts, global_events)
   global_events = global_events or Event.global()

   if self.events:count(event_id) == 0 then
      if not cache[event_id] then
         cache[event_id] = function(source, params, result)
            return global_events:trigger(event_id, source, params, result)
         end
      end

      self.events:register(event_id, string.format("Global event handler (%s)", event_id), cache[event_id], { priority = 0 })
   end

   self.events:register(event_id, name, cb, opts)
end

function IObserver:connect_global(event_id, name, cb, opts, global_events)
   (global_events or Event.global()):add_observer(event_id, self)
   self.global_events:register(event_id, name, cb, opts)
end

return IObserver
