local data = require("internal.data")
local env = require("internal.env")
local EventTree = require("api.EventTree")
local Log = require("api.Log")

local EventHolder = class.class("EventHolder")

function EventHolder:init()
   self.hooks = {}
   self.observers = {}
end

function EventHolder:clear()
   self:init()
end

function EventHolder:serialize()
end

function EventHolder:deserialize()
   self:init()
end

local function check_event(event_id)
   if env.is_loaded("internal.data.base") then
      if data["base.event"][event_id] == nil then
         error("Unknown event type \"" .. event_id .. "\"")
      end
   end
end

function EventHolder:register(event_id, name, cb, opts)
   check_event(event_id)

   if env.is_hotloading() then
      if self:has_handler(event_id, name) then
         Log.warn("Replacing event callback for for %s - \":%s\"", event_id, name)
         return self:replace(event_id, name, cb, opts)
      else
         Log.warn("New event callback hotloaded for %s - \":%s\"", event_id, name)
      end
   end

   if opts == nil then
      opts = {}
   end
   if type(opts) == "number" then
      opts = { priority = opts }
   end
   if name == nil then
      error("Hook name must be provided. (" .. event_id .. ")")
      return
   end
   if cb == nil then
      error("No callback passed to Event.register (" .. event_id .. ")")
      return
   end

   -- BUG: unnecessary if the sort is stable, and incorrect anyways
   local priority = opts.priority or 200000

   self.hooks[event_id] = self.hooks[event_id] or EventTree:new()

   local events = self.hooks[event_id]
   if not events:insert(priority, cb, name) then
      error(string.format("Name is already taken: %s %s", event_id, name))
   end
end

function EventHolder:replace(event_id, name, cb, opts)
   check_event(event_id)

   if opts == nil then
      opts = {}
   end
   if type(opts) == "number" then
      opts = { priority = opts }
   end
   local events = self.hooks[event_id]

   if not events then
      return false
   end

   return self.hooks[event_id]:replace(name, cb, opts.priority)
end

function EventHolder:unregister(event_id, name)
   check_event(event_id)

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
   -- print("emit", event_id)
   check_event(event_id)

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

function EventHolder:responds_to(event_id)
   local hooks = self.hooks[event_id]
   return hooks and hooks:count() > 0
end

function EventHolder:add_observer(event_id, observer)
   local IEventEmitter = require("api.IEventEmitter")
   class.assert_is_an(IEventEmitter, observer)

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
      if self.hooks[event_id] ~= nil then
         return self.hooks[event_id]:print()
      end
      return "(empty)"
   end

   local s = ""

   for k, v in pairs(self.hooks) do
      s = s .. k .. "\n" .. v:print() .. "\n"
   end

   return s
end

function EventHolder:__eq(other)
   local found = {}

   for id, tree in pairs(self.hooks) do
      found[id] = found[id] or {}
      for name, _ in pairs(tree.name_to_ind) do
         found[id][name] = false
      end
   end

   for id, tree in pairs(other.hooks) do
      found[id] = found[id] or {}
      for name, _ in pairs(tree.name_to_ind) do
         if found[id][name] == false then
            found[id][name] = true
         else
            -- A handler was found in the second holder that wasn't
            -- in the first holder.
            return false
         end
      end
   end

   for _, t in pairs(found) do
      for _, was_found in pairs(t) do
         if was_found == false then
            return false
         end
      end
   end

   return true
end

return EventHolder
