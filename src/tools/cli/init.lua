require("internal.data.base")
local fs = require("util.fs")
local Fs = require("api.Fs")
local dir = require("thirdparty.pl.dir")
local env = require("internal.env")
local paths = require("internal.paths")

local argparse = require("thirdparty.argparse")
local Env = require("api.Env")
local Log = require("api.Log")

local function build_app()
   local parser = argparse("opennefia", "An open-source engine reimplementation of Elona.")

   parser:flag("--version", "Prints the version and exits.")
   parser:option("--log-level", "Sets the log level.", "info"):choices({"error", "warn", "info", "debug", "trace"})
   parser:option("--working-dir", "Sets the working directory.", "src/")

   parser:require_command(false)
   parser:command_target("command")

   local run_command = parser:command("run", "Runs the game.")

   local verify_command = parser:command("verify", "Ensures the environment can initialize properly.")
   verify_command:flag("-l --load-game", "Load the full game when verifying.")
   verify_command:flag("-m --load-all-mods", "Load all mods when verifying.")

   local repl_command = parser:command("repl", "Starts the REPL.")
   repl_command:flag("-l --load-game", "Load the full game on startup.")
   repl_command:option("-s --startup-file", "Startup environment file to use.", "src/repl_startup.lua")
       :argname("<lua_file>")

   local test_command = parser:command("test", "Runs tests.")
   test_command:option("-f --filter", "Filter for mod IDs, test files and test function names.", ".*:.*:.*")
       :argname("<filter>")
   test_command:flag("-d --debug-on-error", "Starts a REPL on test failure.")
   test_command:option("-s --seed", "Seed for random number generators.")
       :argname("<seed>")
   test_command:flag("-m --load-all-mods", "Load all mods when testing.")

   do
      local mod_command = parser:command("mod", "Operate on mods.")

      local mod_new_command = mod_command:command("new", "Create a new mod.")
      mod_new_command:argument("mod_id", "Mod ID to use. Must consist of lowercase alphanumerals and underscores only.")

      local mod_deps_command = mod_command:command("dependencies", "Print the dependency tree of a mod.")
      mod_deps_command:argument("mod_id", "Mod ID to inspect.", "")

      local mod_analyze_command = mod_command:command("analyze", "Print the list of data all mods add.")
   end

   local exec_command = parser:command("exec", "Execute a Lua script using the OpenNefia runtime.")
   exec_command:flag("-l --load-game", "Load the full game before executing.")
   exec_command:flag("-r --repl-env", "Execute the script using a REPL env instead of a mod env.")
   exec_command:option("-e --exec-code", "A string containing Lua code to execute.")
   exec_command:flag("-m --load-all-mods", "Load all mods when executing.")
   exec_command:argument("lua_file", "The Lua script to execute. Defaults to standard input.", "-")

   return parser
end

local commands = {}

for _, filepath in fs.iter_directory_paths("tools/cli/commands", true) do
   local basename = fs.to_relative(filepath, "tools/cli/commands")
      :gsub("(.*)%..*", "%1")
      :gsub("/", ".")
   commands[basename] = require(paths.convert_to_require_path(filepath))
end

local function run_app(argv, opts)
   opts = opts or {}
   local app = build_app()
   local args = app:parse(argv)

   Log.set_level(args["log_level"])
   Log.debug(inspect(args))

   if args["version"] then
      print(Env.version())
      return
   end

   local cmd = args["command"] or "run"

   if cmd == "repl" and opts.is_in_repl then
      error("Cannot start the REPL while already in the REPL.")
   end

   local stat = commands[cmd](args)
   return stat
end

return run_app
