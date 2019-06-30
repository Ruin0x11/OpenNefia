local Event = require("api.Event")
local EventHolder = require("api.EventHolder")

--- Interface for adding observer capabilities to an object. This
--- allows them to be notified of any global events that happen.
local IObserver = class.interface("IObserver")

function IObserver:init()
   self.events = EventHolder:new()
end

function IObserver:observes(event_id)
   return self.events:count(event_id) > 0
      or self.events:count("on_event") >= 0
end

function IObserver:send_event(event_id, params, events)
   if not self:observes(event_id) then
      if events then
         events:remove_observer(event_id, self)
      else
         Event.remove_observer(event_id, self)
      end

      return
   end

   return self.events:trigger(event_id, params)
end

function IObserver:observe_event(event_id, name, cb, priority, events)
   if events then
      events:add_observer(event_id, self)
   else
      Event.add_observer(event_id, self)
   end

   self.events:register(event_id, name, cb, priority)
end

function IObserver:unobserve_event(event_id, name, events)
   self.events:unregister(event_id, name)

   if not self:observes(event_id) then
      if events then
         events:remove_observer(event_id, self)
      else
         Event.remove_observer(event_id, self)
      end
   end
end

return IObserver
