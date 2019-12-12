local data = require("internal.data")
local env = require("internal.env")
local paths = require("internal.paths")
local EventTree = require("api.EventTree")
local Log = require("api.Log")

local EventHolder = class.class("EventHolder")

function EventHolder:init()
   self.hooks = {}
   self.observers = {}
   self.registered = {}
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

local function find_calling_chunk()
   local trace = debug.getinfo(4, "S")
   if trace == nil then
      return nil
   end

   local file = trace.source:sub(2)
   return paths.convert_to_require_path(file)
end

--- Called by base.on_hotload_begin.
function EventHolder:_begin_register(chunk)
   self._registered_last_load = self.registered
   self._registering_chunk = chunk
   self.registered = {}
end

--- After hotloading, automatically unregisters any events from a
--- chunk that were registered previously but are now missing from the
--- newly hotloaded chunk. Called by base.on_hotload_end.
function EventHolder:_end_register()
   local prev = self._registered_last_load[self._registering_chunk] or {}
   local cur = self.registered[self._registering_chunk] or {}

   local remove = {}
   for ev, t in pairs(prev) do
      for name, _ in pairs(t) do
         if not (cur[ev] and cur[ev][name]) then
            remove[#remove+1] = { event_id = ev, name = name }
         end
      end
   end

   self.registered = table.merge_ex(self._registered_last_load, self.registered)
   self._registering_chunk = nil
   self._registered_last_load = nil

   if #remove > 0 then
      Log.info("Found %d events missing from chunk, unregistering.", #remove)

      for _, pair in ipairs(remove) do
         Log.info("Unregister %s %s", pair.event_id, pair.name)
         self:unregister(pair.event_id, pair.name)
      end
   end
end

function EventHolder:register(event_id, name, cb, opts)
   check_event(event_id)

   if env.is_hotloading() then
      if self:has_handler(event_id, name) then
         Log.debug("Replacing event callback for for %s - \":%s\"", event_id, name)
         return self:replace(event_id, name, cb, opts)
      else
         Log.debug("New event callback hotloaded for %s - \":%s\"", event_id, name)
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

   local chunk = find_calling_chunk()
   self.registered[chunk] = self.registered[chunk] or {}
   self.registered[chunk][event_id] = self.registered[chunk][event_id] or {}
   self.registered[chunk][event_id][name] = true
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

   local success = self.hooks[event_id]:replace(name, cb, opts.priority)

   if success then
      local chunk = find_calling_chunk()
      self.registered[chunk] = self.registered[chunk] or {}
      self.registered[chunk][event_id] = self.registered[chunk][event_id] or {}
      self.registered[chunk][event_id][name] = true
   end

   return success
end

function EventHolder:unregister(event_id, name)
   check_event(event_id)

   local events = self.hooks[event_id]
   if events then
      events:unregister(name)
   end

   for chunk, t in pairs(self.registered) do
      if t[event_id] then
         t[event_id][name] = nil
      end
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
      if name == nil and next(events) then
         -- Just check if any event handler for event_id is registered
         return true
      end

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
      s = s .. ("= %s =\n%s\n"):format(k, v:print())
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
