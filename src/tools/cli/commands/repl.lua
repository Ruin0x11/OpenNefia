local field = require("game.field")
local startup = require("game.startup")
local fs = require("util.fs")
local Event = require("api.Event")
local mod_info = require("internal.mod_info")
local Stopwatch = require("api.Stopwatch")
local Env = require("api.Env")
local Repl = require("api.Repl")
local elona_repl = require("internal.elona_repl")
local util = require("tools.cli.util")

local function register_thirdparty_module(name)
   local paths = string.format("./thirdparty/%s/?.lua;./thirdparty/%s/?/init.lua", name, name)
   package.path = package.path .. ";" .. paths
end
register_thirdparty_module("repl")

return function(args)
   local sw = Stopwatch:new()

   if not fs.exists(fs.get_save_directory()) then
      fs.create_directory(fs.get_save_directory())
   end

   local mods = mod_info.scan_mod_dir()
   startup.run_all(mods)

   sw:p("REPL startup time")

   Event.trigger("base.on_startup")
   field:init_global_data()

   local repl_env = Repl.generate_env()

   rawset(repl_env, "_PROMPT", "> ")
   rawset(repl_env, "_PROMPT2", ">> ")
   rawset(repl_env, "pass_turn", util.pass_turn)
   rawset(repl_env, "load_game", util.load_game)

   local startup_file = fs.to_relative(args["startup_file"], args.working_dir)
   if fs.exists(startup_file) then
      local chunk = loadfile(startup_file)
      setfenv(chunk, repl_env)
      chunk()
   end

   elona_repl.set_environment(repl_env)

   if args.load_game then
      util.load_game()
   end

   print(string.format("OpenNefia REPL\nVersion: %s  LÖVE version: %s  Lua version: %s  OS: %s",
                       Env.version(), Env.love_version(), Env.lua_version(), Env.os()))
   elona_repl:run()
end
