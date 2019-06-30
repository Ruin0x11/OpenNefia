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
         cb = function() return default end
      end
   end

   local dat = data:add {
      _type = "base.event",
      _id = "hook_" .. id
   }

   local full_id = (dat and dat._id) or nil

   if not env.is_hotloading() then
      assert(dat)
      full_id = dat._id
   end

   local result_extractor
   if type(field) == "function" then
      result_extractor = field
   else
      result_extractor = function(result, default)
         if field == nil then
            return result
         elseif type(result) == "table" and access_field then
            return result[field] or default
         end

         return default
      end
   end

   local func = function(params, _default)
      _default = _default or default
      local success, result = pcall(function() return Event.trigger(full_id, params, _default) end)
      if not success then
         Log.error("Error running hook: %s", result)
         result = _default
      end

      return result_extractor(result, _default)
   end

   local name = string.format("Default hook handler (%s)", full_id)
   Event.register(full_id, name, cb, {priority=100000})

   return func
end

return Event
