Tools = require("mod.tools.api.Tools")
Itemgen = require("mod.tools.api.Itemgen")
Compat = require("mod.elona_sys.api.Compat")
Combat = require("mod.elona.api.Combat")
ElonaAction = require("mod.elona.api.ElonaAction")
ElonaCommand = require("mod.elona.api.ElonaCommand")
Skill = require("mod.elona_sys.api.Skill")
Dialog = require("mod.elona_sys.dialog.api.Dialog")

local test = function()
end

Event.unregister("base.on_game_initialize", "debug")
Event.register("base.on_game_initialize", "debug", function() Repl.defer_execute(test) end)
