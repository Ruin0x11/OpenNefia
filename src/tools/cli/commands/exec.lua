local fs = require("util.fs")
local mod = require("internal.mod")
local startup = require("game.startup")
local Event = require("api.Event")
local field = require("game.field")
local env = require("internal.env")
local util = require("tools.cli.util")

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
   if not fs.exists(fs.get_save_directory()) then
      fs.create_directory(fs.get_save_directory())
   end

   local mods = mod.scan_mod_dir()
   startup.run_all(mods)

   Event.trigger("base.on_startup")
   field:init_global_data()

   if args.load_game then
      util.load_game()
   end

   local chunk = get_chunk(args)
   local exec_env = env.generate_sandbox("exec")
   setfenv(chunk, exec_env)
   chunk()
end
