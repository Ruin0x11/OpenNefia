local Log = require("api.Log")
local EventHolder = require("api.EventHolder")
local env = require("internal.env")
local data = require("internal.data")

local Event = {}

local global_events = require("internal.global.global_events")

local function check_event(event_id)
   if data["base.event"][event_id] == nil then
      error("Unknown event type \"" .. event_id .. "\"")
   end
end

function Event.global()
   return global_events
end

function Event.register(event_id, name, cb, opts)
   if env.is_hotloading() then
      Log.warn("Skipping Event.register for %s - \":%s\"", event_id, name)
      return
   end

   check_event(event_id)
   global_events:register(event_id, name, cb, opts)
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

return Event
