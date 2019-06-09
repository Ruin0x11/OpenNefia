local event_tree = require("internal.event_tree")

local loaded = false

local EventHolder = class("EventHolder")

function EventHolder:init()
   self.hooks = {}
   self.reg = {}
   self.priorities = {}
end

function EventHolder:is_registered(event_id, cb)
   if self.reg[event_id] == nil then
      self.reg[event_id] = {}
      return false
   end
   if self.reg[event_id][cb] then
      return true
   end
   return false
end

function EventHolder:get_events(event_id)
   if self.hooks[event_id] == nil then
      self.hooks[event_id] = event_tree:new()
   end
   return self.hooks[event_id]
end

function EventHolder:register_inner(event_id, cb, priority)
   if self:is_registered(event_id, cb) then
      error("An identical callback was registered twice for an event: " .. event_id)
      return
   end

   self.reg[event_id][cb] = true

   local events = self:get_events(event_id)
   events:insert(priority, cb)
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

   self:register_inner(event_id, cb, priority)
end

function EventHolder:unregister(event_id, cb, opts)
   if opts == nil then
      opts = {}
   end

   if not self:is_registered(event_id, cb) then
      return
   end

   if self.reg[event_id][cb] then
      local events = self:get_events(event_id)
      events:remove_value(cb)
      self.reg[event_id][cb] = nil
   end
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
   if args == nil then
      args = {}
   end
   if type(args) ~= "table" then
      error("Event.register must be passed a table of event arguments as a second argument (got: " .. type(args) .. ").")
   end
   if opts == nil then
      opts = {}
   end

   local events = self:get_events(event_id)
   events:traverse(run_event, args)

   return args
end

return EventHolder
