local event_tree = require("internal.event_tree")
local data = require("internal.data")

local hooks = {}

local reg = {}

local priorities = {}

local event_types = {}
local loaded = false

local Event = {}

local function check_event(event_id)
   if data["base.event"][event_id] == nil then
      error("Unknown event type \"" .. event_id .. "\"")
   end
end

function remove_unknown_events(event_table)
   for k, _ in pairs(event_table) do
      event_types[k] = true
   end

   for k, _ in pairs(hooks) do
      check_event(k)
   end

   loaded = true
end

local function is_registered(event_id, cb)
   if reg[event_id] == nil then
      reg[event_id] = {}
      return false
   end
   if reg[event_id][cb] then
      return true
   end
   return false
end

local function get_events(event_id)
   if hooks[event_id] == nil then
      hooks[event_id] = event_tree:new()
   end
   return hooks[event_id]
end

local function register(event_id, cb, priority)
   if is_registered(event_id, cb) then
      error("An identical callback was registered twice for an event: " .. event_id)
      return
   end

   reg[event_id][cb] = true

   local events = get_events(event_id)
   events:insert(priority, cb)
end

function Event.register(event_id, name, cb, opts)
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

   if loaded then
      check_event(event_id)
   end

   priorities[event_id] = priorities[event_id] or 10000

   local priority = opts.priority or priorities[event_id]

   if not opts.priority then
      priorities[event_id] = priorities[event_id] + 10000
   end

   register(event_id, cb, priority)
end

function Event.unregister(event_id, cb, opts)
   if opts == nil then
      opts = {}
   end
   if loaded then
      check_event(event_id)
   end

   if not is_registered(event_id, cb) then
      return
   end

   if reg[event_id][cb] then
      local events = get_events(event_id)
      events:remove_value(cb)
      reg[event_id][cb] = nil
   end
end

local function run_event(priority, callbacks, args)
   for _, cb in ipairs(callbacks) do
      local result = cb(args)

      if args.stop then
         return false
      end
   end

   return true
end

function Event.trigger(event_id, args, opts)
   if args == nil then
      args = {}
   end
   if type(args) ~= "table" then
      error("Event.register must be passed a table of event arguments as a second argument (got: " .. type(args) .. ").")
   end
   if opts == nil then
      opts = {}
   end
   if loaded then
      check_event(event_id)
   end

   local events = get_events(event_id)
   events:traverse(run_event, args)

   return args
end

return Event
