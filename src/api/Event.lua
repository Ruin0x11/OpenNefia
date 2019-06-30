local Log = require("api.Log")
local EventHolder = require("api.EventHolder")
local env = require("internal.env")
local data = require("internal.data")

local Event = {}

local global_events = require("internal.global.global_events")

local function check_event(event_id)
   if env.is_loaded("internal.data.base") then
      if data["base.event"][event_id] == nil then
         error("Unknown event type \"" .. event_id .. "\"")
      end
   end
end

function Event.global()
   return global_events
end

function Event.register(event_id, name, cb, opts)
   if env.is_hotloading() then
      if global_events:has_handler(event_id, name) then
         Log.warn("Replacing event callback for for %s - \":%s\"", event_id, name)
         return Event.replace(event_id, name, cb, opts)
      else
         Log.warn("New event callback hotloaded for %s - \":%s\"", event_id, name)
      end
   end

   check_event(event_id)
   global_events:register(event_id, name, cb, opts)
end

function Event.replace(event_id, name, cb, opts)
   Log.warn("Event replace: %s - \":%s\"", event_id, name)
   check_event(event_id)
   global_events:replace(event_id, name, cb, opts)
end

function Event.unregister(event_id, cb, opts)
   if env.is_hotloading() then
      Log.warn("Skipping Event.unregister for %s - \":%s\"", event_id, name)
      return
   end

   check_event(event_id)
   global_events:unregister(event_id, cb, opts)
end

function Event.trigger(event_id, args, default)
   if env.is_hotloading() then
      Log.warn("Skipping Event.trigger for %s - \":%s\"", event_id, name)
      return
   end

   check_event(event_id)
   return global_events:trigger(event_id, "global", args, default)
end

function Event.list(event_id)
   return global_events:print(event_id)
end

function Event.hook(id, desc, default, field, cb)
   local access_field = type(field) == "string"

   if cb == nil then
      if access_field then
         cb = function() return {} end
      else
         cb = function() return nil end
      end
   end

   local dat = data:add {
      _type = "base.event",
      _id = id
   }

   local full_id = (dat and dat._id) or nil

   if not env.is_hotloading() then
      assert(dat)
      full_id = dat._id
   end

   local func = function(params, _default)
      _default = _default or default
      local success, result = pcall(function() return Event.trigger(full_id, params, _default) end)
      if not success then
         Log.error("Error running hook: %s", result)
         return default
      end

      local final

      if field == nil then
         final = result
      elseif type(result) == "table" and access_field then
         final = result[field]
      else
         final = nil
      end

      if final == nil then
         final = _default
      end
      _p(final,default,_default,full_id)

      return final
   end

   local name = string.format("Default hook handler (%s)", full_id)
   if env.is_hotloading() then
      Log.info("In-place hook update for %s", name)
      Event.replace(full_id, name, cb, {priority=100000})
   else
      Log.info("Registering new hook: %s", tostring(full_id))
      Event.register(full_id, name, cb, {priority=100000})
   end

   return func
end

return Event
