local startup = require("game.startup")
local mod = require("internal.mod")
local repl = require("internal.repl")

return function()
   require("internal.data.base")

   local mods = mod.scan_mod_dir()
   startup.run_all(mods)

   repl.require_all_apis()
   repl.require_all_apis("internal")
   repl.require_all_apis("game")
end
