local fs = require("util.fs")
local mod = require("internal.mod")
local startup = require("game.startup")
local Event = require("api.Event")
local field = require("game.field")
local env = require("internal.env")
local util = require("tools.cli.util")
local Repl = require("api.Repl")

local function get_chunk(args)
   if args.exec_code then
      return assert(loadstring(args.exec_code))
   elseif args.lua_file == "-" then
      local str = io.stdin:read("*a")
      return assert(loadstring(str))
   else
      local path = fs.to_relative(args.lua_file, args.working_dir)
      return assert(loadfile(path))
   end
end

return function(args)
   local chunk = get_chunk(args)

   if not fs.exists(fs.get_save_directory()) then
      fs.create_directory(fs.get_save_directory())
   end

   local enabled_mods
   if args.load_all_mods then
      enabled_mods = nil
   else
      enabled_mods = { "base", "elona_sys", "elona", "extlibs" }
   end
   local mods = mod.scan_mod_dir(enabled_mods)
   startup.run_all(mods)

   Event.trigger("base.on_startup")
   field:init_global_data()

   if args.load_game then
      util.load_game()
   end

   local exec_env
   if args.exec_env == "repl" then
      exec_env = Repl.generate_env()
      rawset(exec_env, "pass_turn", util.pass_turn)
      rawset(exec_env, "load_game", util.load_game)
   elseif args.exec_env == "global" then
      exec_env = _G
   else
      exec_env = env.generate_sandbox("exec")
   end

   setfenv(chunk, exec_env)
   chunk()
end
