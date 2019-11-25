Tools = require("mod.tools.api.Tools")
Itemgen = require("mod.tools.api.Itemgen")
Charagen = require("mod.tools.api.Charagen")
Compat = require("mod.elona_sys.api.Compat")
Benchmark = require("mod.tools.api.Benchmark")

Log.set_level("debug")

local test = function()
end

Event.unregister("base.on_game_initialize", "debug")
Event.register("base.on_game_initialize", "debug", function() Repl.defer_execute(test) end)
