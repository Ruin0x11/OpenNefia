local Event = require("api.Event")
local DebugStatsHook = require("mod.tools.api.debug.DebugStatsHook")

Event.register("base.on_hotload_end", "Reset debug hook", DebugStatsHook.clear_results, {priority = 100000})
