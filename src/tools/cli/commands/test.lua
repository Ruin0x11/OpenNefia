local field = require("game.field")
local mod = require("internal.mod")
local startup = require("game.startup")
local fs = require("util.fs")
local Event = require("api.Event")
local env = require("internal.env")
local socket = require("socket")
local Rand = require("api.Rand")
local config = require("internal.config")
local elona_repl = require("internal.elona_repl")
local Repl = require("api.Repl")
local ansicolors = require("thirdparty.ansicolors")
local Log = require("api.Log")

-- Make an environment rejecting the setting of global variables except
-- functions that are named "test_*".
local function make_test_env()
   local tests = env.generate_sandbox("__test__")

   local mt = { __tests = {}, __declared = {} }

   function mt.__newindex(t, k, v)
      if type(k) == "string" and string.match(k, "^test_") and type(v) == "function" then
         table.insert(mt.__tests, {k, v})
         rawset(t, k, v)
      else
         if not mt.__declared[k] then
            local w = debug.getinfo(2, "S").what
            if w ~= "main" and w ~= "C" then
               error("assign to undeclared variable '"..k.."'", 2)
            end
            mt.__declared[k] = true
         end
         rawset(t, k, v)
      end
   end

   function mt.__index(t, k)
      if not mt.__declared[k] then
         error("variable '"..k.."' is not declared", 2)
      end
      return rawget(t, k)
   end

   return setmetatable(tests, mt), mt
end

local function run_test(name, test_fn, seed, debug_on_error)
   Rand.set_seed(seed)

   local locals
   local function capture(err)
      local repl = require("internal.repl")
      locals = repl.capture_locals(2)
      if type(err) == "table" then
         for k, v in pairs(err) do
            if type(k) == "string" then
               rawset(locals, k, v)
            end
         end
         err = tostring(err[1])
      end
      return debug.traceback(err)
   end

   local ok, err = xpcall(test_fn, capture)

   if ok then
      io.write(ansicolors("%{green}.%{reset}"))
      return true
   else
      io.write(ansicolors("%{red}F\n" .. name .. "\n============\n%{reset}" .. err .. "\n\n"))

      if debug_on_error then
         local repl_env, history = Repl.generate_env(locals)
         elona_repl.set_environment(repl_env)
         print(inspect(table.keys(locals)))
         elona_repl:run()
      end

      return false
   end
end

local function test_file(file, filter_test_name, seed, debug_on_error)
   local chunk = assert(loadfile(file))
   local test_env, mt = make_test_env()

   setfenv(chunk, test_env)

   chunk()

   local failures = 0
   local total = 0

   for _, pair in ipairs(mt.__tests) do
      local name = pair[1]
      local test_fn = pair[2]

      if string.match(name, filter_test_name) then
         local success = run_test(name, test_fn, seed, debug_on_error)
         if not success then
            failures = failures + 1
         end
         total = total + 1
      end
   end

   return failures, total
end

return function(args)
   if not fs.exists(fs.get_save_directory()) then
      fs.create_directory(fs.get_save_directory())
   end

   local mods = mod.scan_mod_dir()
   startup.run_all(mods)

   Event.trigger("base.on_startup")
   field:init_global_data()

   local seed = args.seed or math.floor(socket.gettime())
   config.base.default_seed = seed

   print("Seed: " .. seed)
   print("")

   local spl = string.split(args.filter, ":")
   local filter_file_name = spl[1]
   local filter_test_name = spl[2] or ".*"

   Log.warn("Test filter: %s:%s", filter_file_name, filter_test_name)

   local failures = 0
   local total = 0

   for _, file in fs.iter_directory_items("test/unit/") do
      if string.match(file, filter_file_name) then
         local path = fs.join("test/unit/", file)
         local failures_, total_ = test_file(path, filter_test_name, seed, args.debug_on_error)
         failures = failures + failures_
         total = total + total_
      end
   end

   if failures > 0 then
      error(("%d/%d failing tests."):format(failures, total))
   end
end
