local env = require("internal.env")
local Event = require("api.Event")

-- The following adds support for cleaning up missing events
-- automatically if a chunk is hotloaded. It assumes only one chunk is
-- being loaded at a time, and does not handle hotloading dependencies
-- recursively.

local function on_hotload_begin(_, params)
   -- strip trailing "init" to make the path unique
   local path = env.convert_to_require_path(params.path_or_class)
   Event.global():_begin_register(path)
end

local function on_hotload_end()
   Event.global():_end_register()
end

Event.register("base.on_hotload_begin", "Clean up events missing in chunk on hotload", on_hotload_begin)
Event.register("base.on_hotload_end", "Clean up events missing in chunk on hotload", on_hotload_end)
