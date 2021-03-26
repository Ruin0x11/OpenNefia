local Map = require("api.Map")
local IEventEmitter = require("api.IEventEmitter")
local Event = require("api.Event")
local paths = require("internal.paths")
local IMapObject = require("api.IMapObject")
local ILocation = require("api.ILocation")
local Log = require("api.Log")
local draw = require("internal.draw")
local IUiLayer = require("api.gui.IUiLayer")

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

Event.register("base.on_object_prototype_changed", "reload events for object",
               function(obj, params)
                  if not params.no_bind_events and class.is_an(IEventEmitter, obj) then
                     IEventEmitter.on_reload_prototype(obj, params.old_id)
                  end
               end,
               {priority = 1000})

Event.register("base.on_hotload_end", "Notify objects in map of prototype hotload",
               function(_, params)
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
end)

local function rebind_ui_layer_keys()
   -- BUG doesn't work for forwards
   local current = draw.get_current_layer()
   if current and class.is_an(IUiLayer, current.layer) then
      local keymap = current.layer:make_keymap()
      current.layer:bind_keys(keymap)
   end
end
Event.register("base.on_hotload_end", "Rebind keys of current UILayer", rebind_ui_layer_keys)
