local event_tree = require("internal.event_tree")

local loaded = false

local EventHolder = class("EventHolder")

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

   self.hooks[event_id] = self.hooks[event_id] or event_tree:new()

   local events = self.hooks[event_id]
   if not events:insert(priority, cb, name) then
      error(string.format("Name is already taken: %s %s", event_id, name))
   end
end

function EventHolder:unregister(event_id, name, opts)
   if opts == nil then
      opts = {}
   end

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

local function run_event(priority, callbacks, args)
   for _, cb in ipairs(callbacks) do
      local result = cb(args)

      if type(result) == "table" then
         args = table.merge(args, result)
      end

      if args._stop then
         return false
      end
   end

   return true
end

function EventHolder:trigger(event_id, args, opts)
   args = args or {}
   opts = opts or {}
   if type(args) ~= "table" then
      error("Event.register must be passed a table of event arguments as a second argument (got: " .. type(args) .. ").")
   end

   if event_id ~= "on_event" then
      self:trigger("on_event", { event_id = event_id, args = args })
   end

   local events = self.hooks[event_id]
   if events then
      events:traverse(run_event, args)
   end

   if self.observers[event_id] then
      local data = require("internal.data")
      local event = data["base.event"][event_id]
      local field = opts.observer or (event and event.observer)
      local run_all = true

      if field then
         local observer = args[field]
         local strict = false

         -- Send the event even if the value of the designated field
         -- is not registered as an observer for this event.
         local should_send = observer ~= nil
            and (not strict or self.observers[event_id][observer] == true)

         if should_send then
            run_all = false
            observer:send_event(event_id, args)
         end
      end

      if run_all then
         for observer, _ in pairs(self.observers[event_id]) do
            observer:send_event(event_id, args)
         end
      end
   end

   return args
end

function EventHolder:add_observer(event_id, observer)
   local IObserver = require("api.IObserver")
   assert_is_an(IObserver, observer)

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
