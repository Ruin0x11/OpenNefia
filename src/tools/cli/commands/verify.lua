local startup = require("game.startup")
local mod = require("internal.mod")
local repl = require("internal.repl")
local util = require("tools.cli.util")

return function(args)
   require("internal.data.base")

   local enabled_mods = { "base", "elona_sys", "elona", "extlibs" }
   local mods = mod.scan_mod_dir(enabled_mods)
   startup.run_all(mods)

   repl.require_all_apis()
   repl.require_all_apis("internal")
   repl.require_all_apis("game")

   if args.load_game then
      util.load_game()
   end
end
