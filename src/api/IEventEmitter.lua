--- @module IEventEmitter

local Event = require("api.Event")
local EventHolder = require("api.EventHolder")
local Log = require("api.Log")
local data = require("internal.data")

local IEventEmitter = class.interface("IEventEmitter")

function IEventEmitter:init(events)
   self._events = EventHolder:new()
   self.global_events = EventHolder:new()
end

function IEventEmitter:on_reload_prototype(old_id)
   -- XXX: removing old events is broken since can't compare the previous
   -- instance before hotloading
   local events = self.proto and self.proto.events
   if events then
      Log.debug("Loading %d events of %s:%s for object %d", #events, self._type, self._id, self.uid)
      self:connect_self_multiple(events, true)
   end
end

local cache = {}

local function global_callback_id_for(event_id)
   return ("Global callback runner (%s)"):format(event_id)
end

local function register_global_handler_if_needed(self, event_id, global_events)
   if self._events:count(event_id) == 0 then
      global_events = global_events or Event.global()
      if not cache[event_id] then
         cache[event_id] = function(source, params, result)
            -- XXX: To be compatible with "block the rest of the events", the
            -- below code also needed to return the status of the event handler.
            --
            -- For example, say you have a statue or gemstone that has an
            -- "on_use" callback. This will be registered locally on the item's
            -- IEventEmitter fields. Now say that you want to have a "cooldown
            -- time" that can be applied to anything that can be used, including
            -- said gemstone. If the cooldown time has not passed when the item
            -- is used, then we want to block the rest of the events that might
            -- get called. This event that does the blocking will get registered
            -- globally (inside `global_events`).
            --
            -- Problem is, when "blocked" was passed as the second return value
            -- in the global event handlers, it only stayed local to the global
            -- event tree. The fix was to also return the status so we can
            -- bubble it up here.
            local new_result, _args, status = global_events:trigger(event_id, source, params, result)

            return new_result, status
         end
      end

      self._events:register(event_id, global_callback_id_for(event_id), cache[event_id], { priority = 100000 })
   end
end

local function unregister_global_handler_if_needed(self, event_id)
   if cache[event_id] and self._events:count(event_id) == 1 then
      local global_callback_id = global_callback_id_for(event_id)
      if self:has_event_handler(event_id, global_callback_id) then
         self._events:unregister(event_id, global_callback_id)
         assert(not self:has_event_handler(event_id))
      end
   end
end

--- Causes this object to emit an event.
---
--- This will run the event handlers for `event_id` registered for
--- this object and return the result that is passed down from the
--- final handler. Some events may require the use of parameters and
--- return values, while others may not; this depends on the type of
--- event being handled.
---
--- `params` is a key-value table of parameters to pass to the event.
--- The specific parameters you can pass depend on which event you are
--- handling; check the event's documentation for details.
---
--- `result` is the default return value of the event handling to
--- return if no result is returned by any event (e.g. all event
--- callbacks return `nil`).
---
--- Events are handled based on the priority of each handler. You can
--- use `IEventEmitter:connect_self()` to connect more event handlers
--- to just this object individually. To run code whenever *any*
--- object emits an event, or the event is triggered globally, use
--- `Event.register().`
---
--- @tparam id:base.event event_id
--- @tparam[opt] table params Parameters to be passed to the event;
---   this differs depending on the event ID. Some events may require
---   the usage of parameters while others may not.
--- @tparam[opt] any result Starting result of the event. Can be nil to
---   use the default result returned by the event.
--- @tparam[opt] EventHolder global_events
function IEventEmitter:emit(event_id, params, result, global_events)
   register_global_handler_if_needed(self, event_id, global_events)

   if event_id == "base.before_handle_self_event" then
      return nil
   end

   self:emit("base.before_handle_self_event", {event_id = event_id, params = params, result = result})

   return self._events:trigger(event_id, self, params, result)
end

--- Triggers the event handlers registered in the global namespace for
--- an event, ignoring any that have been set individually on this
--- event emitter.
---
--- @tparam id:base.event event_id
--- @tparam[opt] table params Parameters to be passed to the event;
---   this differs depending on the event ID. Some events may require
---   the usage of parameters while others may not.
--- @tparam[opt] any result Starting result of the event. Can be nil to
---   use the default result returned by the event.
function IEventEmitter:trigger_global(event_id, params, result)
   return self.global_events:trigger(event_id, self, params, result)
end

--- Returns true if this emitter has an individually registered event
--- for the provided ID (not counting globally registered events).
---
--- @tparam id:base.event event_id
--- @tparam string name Fully qualified name of the registered event.
function IEventEmitter:has_event_handler(event_id, name)
   return self._events:has_handler(event_id, name)
end

--- Registers an individual event handler for an event.
---
--- @tparam id:base.event event_id
--- @tparam string name A uniquely idenfiying name for the event;
---   intended for debugging use. Can be as long as needed. Please be
---   descriptive in the event's behavior to aid discovery.
--- @tparam function cb Event callback.
--- @tparam[opt] table opts
--- @tparam[opt] EventHolder global_events
function IEventEmitter:connect_self(event_id, name, cb, opts, global_events, force)
   data["base.event"]:ensure(event_id)

   if self:has_event_handler(event_id, name) and force then
      self:disconnect_self(event_id, name)
   end

   register_global_handler_if_needed(self, event_id, global_events)

   self._events:register(event_id, name, cb, opts)
end

--- Removes an individual event handler for an event.
---
--- @tparam id:base.event event_id
--- @tparam string name The name the handler was registered with
function IEventEmitter:disconnect_self(event_id, name)
   data["base.event"]:ensure(event_id)

   self._events:unregister(event_id, name)

   unregister_global_handler_if_needed(self, event_id)
end

function IEventEmitter:disconnect_self_multiple(events)
   for _, event in ipairs(events) do
      Log.trace("Disonnecting callback: %s %s", event.id, event.name)
      self:disconnect_self(event.id, event.name)
   end
end

function IEventEmitter:connect_self_multiple(events, force)
   for _, event in ipairs(events) do
      Log.trace("Connecting callback: %s %s", event.id, event.name)
      self:connect_self(event.id, event.name, event.callback, event.priority or 100000, nil, force)
   end
end

--- Registers an global event handler for an event.
---
--- @tparam id:base.event event_id
--- @tparam string name A uniquely idenfiying name for the event;
---   intended for debugging use. Can be as long as needed. Please be
---   descriptive in the event's behavior to aid discovery.
--- @tparam function cb Event callback.
--- @tparam[opt] table opts
--- @tparam[opt] EventHolder global_events
function IEventEmitter:connect_global(event_id, name, cb, opts, global_events)
   (global_events or Event.global()):add_observer(event_id, self)
   self.global_events:register(event_id, name, cb, opts)
end

function IEventEmitter:compare_events(other)
   return self._events:compare(other._events)
end

function IEventEmitter:list_events(event_id)
   return self._events:print(event_id)
end

return IEventEmitter
