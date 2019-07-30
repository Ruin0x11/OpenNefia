local Event = require("api.Event")
local EventHolder = require("api.EventHolder")

local IEventEmitter = class.interface("IEventEmitter")

function IEventEmitter:init()
   self._events = EventHolder:new()
   self.global_events = EventHolder:new()

   if self.events then
      for _, event in ipairs(self.events) do
         self:connect_self(event.id, event.name, event.callback, event.priority or 100000)
      end
   end
end

local cache = {}

local function register_global_handler_if_needed(self, event_id, global_events)
   if self._events:count(event_id) == 0 then
      global_events = global_events or Event.global()
      if not cache[event_id] then
         cache[event_id] = function(source, params, result)
            return global_events:trigger(event_id, source, params, result)
         end
      end

      self._events:register(event_id, string.format("Global callback runner (%s)", event_id), cache[event_id], { priority = 0 })
   end
end

function IEventEmitter:emit(event_id, params, result, global_events)
   register_global_handler_if_needed(self, event_id, global_events)

   if event_id == "base.before_handle_self_event" then
      return nil
   end

   self:emit("base.before_handle_self_event", {event_id = event_id, params = params, result = result})

   return self._events:trigger(event_id, self, params, result)
end

function IEventEmitter:trigger_global(event_id, params, result)
   return self.global_events:trigger(event_id, self, params, result)
end

function IEventEmitter:has_event_handler(event_id, name)
   return self._events:has_handler(event_id, name)
end

function IEventEmitter:connect_self(event_id, name, cb, opts, global_events)
   register_global_handler_if_needed(self, event_id, global_events)

   self._events:register(event_id, name, cb, opts)
end

function IEventEmitter:disconnect_self(event_id, name)
   self._events:unregister(event_id, name)

   if self._events:count(event_id) == 0 then
      self._events:unregister(event_id, string.format("Global callback runner (%s)", event_id))
   end
end

function IEventEmitter:connect_global(event_id, name, cb, opts, global_events)
   (global_events or Event.global()):add_observer(event_id, self)
   self.global_events:register(event_id, name, cb, opts)
end

-- Disconnects all self event handlers across all event types that
-- match `name`.
-- @tparam string name a string or regex
function IEventEmitter:disconnect_self_matching(name)
   -- TODO
end

-- Disconnects all global event handlers across all event types that
-- match `name`.
-- @tparam string name a string or regex
function IEventEmitter:disconnect_global_matching(name)
   -- TODO
end

return IEventEmitter
