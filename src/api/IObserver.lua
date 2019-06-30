local Event = require("api.Event")
local EventHolder = require("api.EventHolder")

local IObserver = class.interface("IObserver")

function IObserver:init()
   self.events = EventHolder:new()
   self.global_events = EventHolder:new()
end

local cache = {}

local function register_global_handler_if_needed(self, event_id, global_events)
   if self.events:count(event_id) == 0 then
      global_events = global_events or Event.global()
      if not cache[event_id] then
         cache[event_id] = function(source, params, result)
            return global_events:trigger(event_id, source, params, result)
         end
      end

      self.events:register(event_id, string.format("Global callback runner (%s)", event_id), cache[event_id], { priority = 0 })
   end
end

function IObserver:emit(event_id, params, result, global_events)
   register_global_handler_if_needed(self, event_id, global_events)

   if event_id == "base.before_handle_self_event" then
      return nil
   end

   self:emit("base.before_handle_self_event", {event_id = event_id, params = params, result = result})

   return self.events:trigger(event_id, self, params, result)
end

function IObserver:trigger_global(event_id, params, result)
   return self.global_events:trigger(event_id, self, params, result)
end

function IObserver:has_event_handler(event_id, name)
   return self.events:has_handler(event_id, name)
end

function IObserver:connect_self(event_id, name, cb, opts, global_events)
   register_global_handler_if_needed(self, event_id, global_events)

   self.events:register(event_id, name, cb, opts)
end

function IObserver:disconnect_self(event_id, name)
   self.events:unregister(event_id, name)

   if self.events:count(event_id) == 0 then
      self.events:unregister(event_id, string.format("Global callback runner (%s)", event_id))
   end
end

function IObserver:connect_global(event_id, name, cb, opts, global_events)
   (global_events or Event.global()):add_observer(event_id, self)
   self.global_events:register(event_id, name, cb, opts)
end

-- Disconnects all self event handlers across all event types that
-- match `name`.
-- @tparam string name a string or regex
function IObserver:disconnect_self_matching(name)
   -- TODO
end

-- Disconnects all global event handlers across all event types that
-- match `name`.
-- @tparam string name a string or regex
function IObserver:disconnect_global_matching(name)
   -- TODO
end

return IObserver
