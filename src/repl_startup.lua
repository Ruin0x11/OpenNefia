---
--- This file is run when the REPL starts up and affects its private
--- environment. Any globals set here will be accessable in the REPL.
---

Tools = require("mod.tools.api.Tools")
Itemgen = require("mod.tools.api.Itemgen")
Charagen = require("mod.tools.api.Charagen")
Compat = require("mod.elona_sys.api.Compat")
Benchmark = require("mod.tools.api.Benchmark")
Magic = require("mod.elona_sys.api.Magic")
Effect = require("mod.elona.api.Effect")
Quest = require("mod.elona_sys.api.Quest")
Scene = require("mod.elona_sys.scene.api.Scene")
Mx = require("mod.tools.api.Mx")
ElonaCommand = require("mod.elona.api.ElonaCommand")
PicViewer = require("mod.tools.api.PicViewer")
Skill = require("mod.elona_sys.api.Skill")
Wish = require("mod.elona.api.Wish")
PlotViewer = require("mod.plot.api.PlotViewer")

Log.set_level("info")

local test = function()
end

Event.unregister("base.on_game_initialize", "debug")
Event.register("base.on_game_initialize", "debug", function() Repl.defer_execute(test) end)

p = Chara.player()

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
