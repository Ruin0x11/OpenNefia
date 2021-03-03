local Map = require("api.Map")
local IEventEmitter = require("api.IEventEmitter")
local Event = require("api.Event")
local paths = require("internal.paths")
local IMapObject = require("api.IMapObject")
local ILocation = require("api.ILocation")
local Log = require("api.Log")

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

Event.register("base.on_object_prototype_changed", "reload events for object", function(obj, params)
                  if class.is_an(IEventEmitter, obj) then
                     IEventEmitter.on_reload_prototype(obj, params.old_id)
                  end
end)

Event.register("base.on_map_loaded", "init all event callbacks",
               function(map)
                  local objs = map:iter():to_list()
                  while #objs > 0 do
                     local v = objs[#objs]
                     objs[#objs] = nil

                     -- Event callbacks will not be serialized since
                     -- they are functions, so they have to be copied
                     -- from the prototype each time.
                     if class.is_an(IEventEmitter, v) then
                        IEventEmitter.init(v)
                     end
                     v:instantiate()
                     if class.is_an(ILocation, v) then
                        table.append(objs, v:iter():to_list())
                     end
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
