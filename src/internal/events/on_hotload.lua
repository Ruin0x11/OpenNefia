local Map = require("api.Map")
local IEventEmitter = require("api.IEventEmitter")
local Event = require("api.Event")
local paths = require("internal.paths")

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

Event.register("base.on_map_loaded", "init all event callbacks",
               function(map)
                  for _, v in map:iter() do
                     -- Event callbacks will not be serialized since
                     -- they are functions, so they have to be copied
                     -- from the prototype each time.
                     if class.is_an(IEventEmitter, v) then
                        IEventEmitter.init(v)
                     end
                     v:instantiate()
                  end
               end)

Event.register("base.on_hotload_end", "Notify objects in map of prototype hotload",
               function(_, params)
                  local map = Map.current()
                  if map then
                     local hotloaded = {}
                     for _, v in ipairs(params.hotloaded_data) do
                        hotloaded[v._type] = hotloaded[v._type] or {}
                        hotloaded[v._type][v._id] = true
                     end
                     for _, obj in map:iter() do
                        if class.is_an(IEventEmitter, obj)
                           and hotloaded[obj._type]
                           and hotloaded[obj._type][obj._id]
                        then
                           obj:emit("base.on_hotload_object", params)
                        end
                     end
                  end
end)
