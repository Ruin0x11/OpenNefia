local startup = require("game.startup")
local mod_info = require("internal.mod_info")
local repl = require("internal.repl")
local util = require("tools.cli.util")

return function(args)
   require("internal.data.base")

   local enabled_mods
   if args.load_all_mods then
      enabled_mods = nil
   else
      enabled_mods = { "base", "elona_sys", "elona", "extlibs" }
   end
   local mods = mod_info.scan_mod_dir(enabled_mods)
   startup.run_all(mods)

   repl.require_all_apis()
   repl.require_all_apis("internal")
   repl.require_all_apis("game")

   if args.load_game then
      util.load_game()
   end
end
