local Map = require("api.Map")
local IEventEmitter = require("api.IEventEmitter")
local Event = require("api.Event")
local paths = require("internal.paths")
local IMapObject = require("api.IMapObject")
local ILocation = require("api.ILocation")
local Log = require("api.Log")
local draw = require("internal.draw")
local IUiLayer = require("api.gui.IUiLayer")
local SaveFs = require("api.SaveFs")
local env = require("internal.env")

-- The following adds support for cleaning up missing events
-- automatically if a chunk is hotloaded. It assumes only one chunk is
-- being loaded at a time, and does not handle hotloading dependencies
-- recursively.

local function on_hotload_begin(_, params)
   -- strip trailing "init" to make the path unique
   local path = paths.convert_to_require_path(params.path_or_class)
   Event.global():_begin_register(path)
end

local function on_hotload_end()
   Event.global():_end_register()
end

Event.register("base.on_hotload_begin", "Clean up events missing in chunk on hotload", on_hotload_begin, {priority = 1})
Event.register("base.on_hotload_end", "Clean up events missing in chunk on hotload", on_hotload_end, {priority = 9999999999})

local function reload_object_events(obj, params)
   if not params.no_bind_events and class.is_an(IEventEmitter, obj) then
      IEventEmitter.on_reload_prototype(obj, params.old_id)
   end
end
Event.register("base.on_object_prototype_changed", "reload events for object", reload_object_events, {priority = 1000})

local function notify_objects_of_hotload(_, params)
   local map = Map.current()
   if map then
      local hotloaded = {}
      for _, v in ipairs(params.hotloaded_data) do
         hotloaded[v._type] = hotloaded[v._type] or {}
         hotloaded[v._type][v._id] = true
      end

      local stack = {map}
      local found = table.set {}

      -- Handle nested containers and hotload all inner objects
      while #stack > 0 do
         local thing = stack[#stack]
         stack[#stack] = nil

         if not found[thing] then
            found[thing] = true
            if class.is_an(IMapObject, thing)
               and class.is_an(IEventEmitter, thing)
               and hotloaded[thing._type]
               and hotloaded[thing._type][thing._id]
            then
               Log.debug("Load " .. thing._type .. " " .. thing._id)
               thing:instantiate()
               thing:emit("base.on_hotload_object", params)
            end

            if class.is_an(ILocation, thing) then
               for _, obj in thing:iter() do
                  stack[#stack+1] = obj
               end
            end
         end
      end
   end
end
Event.register("base.on_hotload_end", "Notify objects in map of prototype hotload", notify_objects_of_hotload)

local function rebind_ui_layer_keys()
   -- BUG doesn't work for forwards
   local current = draw.get_current_layer()
   if current and class.is_an(IUiLayer, current.layer) then
      local keymap = current.layer:make_keymap()
      current.layer:bind_keys(keymap)
   end
end
Event.register("base.on_hotload_end", "Rebind keys of current UILayer", rebind_ui_layer_keys)

local stats = { times_hotloaded = {} }
local STATS_FILE = "data/hotload_stats"
local function load_hotload_stats()
   if SaveFs.exists(STATS_FILE, "global") then
      local ok, stats_ = SaveFs.read(STATS_FILE, "global")
      if ok then
         stats = stats_
      end
   end
end
Event.register("base.on_engine_init", "Load hotload stats", load_hotload_stats)

local function save_hotload_stats(_, params)
   local path = params.path_or_class
   if type(path) == "table" then
      path = env.get_require_path(path)
   end
   if type(path) == "string" then
      stats.times_hotloaded[path] = (stats.times_hotloaded[path] or 0) + 1
      SaveFs.write(STATS_FILE, stats, "global")
   end
end
Event.register("base.on_hotload_end", "Save hotload stats", save_hotload_stats)
