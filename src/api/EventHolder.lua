local EventTree = require("api.EventTree")

local EventHolder = class.class("EventHolder")

function EventHolder:init()
   self.hooks = {}
   self.priorities = {}
   self.observers = {}
end

function EventHolder:clear()
   self.hooks = {}
   self.priorities = {}
   self.observers = {}
end

function EventHolder:register(event_id, name, cb, opts)
   if opts == nil then
      opts = {}
   end
   if name == nil then
      error("Hook name must be provided. (" .. event_id .. ")")
      return
   end
   if cb == nil then
      error("No callback passed to Event.register (" .. event_id .. ")")
      return
   end

   self.priorities[event_id] = self.priorities[event_id] or 10000

   local priority = opts.priority or self.priorities[event_id]

   if not opts.priority then
      self.priorities[event_id] = self.priorities[event_id] + 10000
   end

   self.hooks[event_id] = self.hooks[event_id] or EventTree:new()

   local events = self.hooks[event_id]
   if not events:insert(priority, cb, name) then
      error(string.format("Name is already taken: %s %s", event_id, name))
   end
end

function EventHolder:unregister(event_id, name, opts)
   opts = opts or {}

   local events = self.hooks[event_id]
   if events then
      events:unregister(name)
   end
end

function EventHolder:count(event_id)
   local events = self.hooks[event_id]
   if events == nil then
      return 0
   end
   return events:count()
end

function EventHolder:trigger(event_id, source, args, default)
   args = args or {}
   local result = default

   local events = self.hooks[event_id]
   if events then
      result = events:trigger(source, args, result)
   end

   local observers = self.observers[event_id]
   if observers then
      for observer, _ in pairs(observers) do
         result = observer:trigger_global(event_id, args, result)
      end
   end

   return result, args
end

function EventHolder:add_observer(event_id, observer)
   local IObserver = require("api.IObserver")
   class.assert_is_an(IObserver, observer)

   self.observers[event_id] = self.observers[event_id] or setmetatable({}, { __mode = "k" })
   self.observers[event_id][observer] = true
end

function EventHolder:remove_observer(event_id, observer)
   self.observers[event_id] = self.observers[event_id] or setmetatable({}, { __mode = "k" })
   self.observers[event_id][observer] = nil
end

function EventHolder:disable(event_id, name)
   local events = self.hooks[event_id]
   if events then
      return events:disable(name)
   end
end

function EventHolder:enable(event_id, name)
   local events = self.hooks[event_id]
   if events then
      return events:enable(name)
   end
end

function EventHolder:has_handler(event_id, name)
   local events = self.hooks[event_id]
   if events then
      return events:has_handler(name)
   end

   return false
end

function EventHolder:print(event_id)
   if event_id ~= nil then
      return self.hooks[event_id]:print()
   end

   local s = ""

   for k, v in pairs(self.hooks) do
      s = s .. k .. "\n" .. v:print() .. "\n"
   end

   return s
end

return EventHolder
