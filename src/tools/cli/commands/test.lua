local field = require("game.field")
local mod = require("internal.mod")
local startup = require("game.startup")
local fs = require("util.fs")
local Event = require("api.Event")
local env = require("internal.env")
local socket = require("socket")
local Rand = require("api.Rand")
local elona_repl = require("internal.elona_repl")
local Repl = require("api.Repl")
local ansicolors = require("thirdparty.ansicolors")
local Log = require("api.Log")
local config_store = require("internal.config_store")
local save_store = require("internal.save_store")
local SaveFs = require("api.SaveFs")

-- Make an environment rejecting the setting of global variables except
-- functions that are named "test_*".
local function make_test_env()
   local tests = env.generate_sandbox("__test__")
   tests.require = require

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

local function cleanup_globals()
   config_store.clear()
   save_store.clear()
   fs.remove(fs.parent(SaveFs.save_path("", "save", "__test__")))
   fs.remove(SaveFs.save_path("", "temp"))
   fs.remove(SaveFs.save_path("", "global"))
   field:init_global_data()
end

local function print_result(result)
   io.write(ansicolors("%{red}\nFailure: " .. result.test_name .. "\n"))
   io.write(ansicolors("============(traceback)\n%{reset}" .. result.traceback .. "\n"))
   io.write("============(stdout)\n" .. result.stdout .. "")
   io.write("============\n")
end

local function run_test(name, test_fn, seed, debug_on_error)
   cleanup_globals()
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

   local StringIO = require("mod.extlibs.api.StringIO")
   local _print = print
   local redir_out = StringIO.create()
   print = function(...) for _, i in ipairs({...}) do redir_out:write(i .. "\n") end end

   local ok, err = xpcall(test_fn, capture)

   print = _print

   if ok then
      io.write(ansicolors("%{green}.%{reset}"))
      return true, nil
   else
      io.write(ansicolors("%{red}F"))

      local result = {
         test_name = name,
         traceback = err,
         stdout = tostring(redir_out)
      }

      if debug_on_error then
         print_result(result)
         local repl_env, history = Repl.generate_env(locals)
         elona_repl.set_environment(repl_env)
         print(inspect(table.keys(locals)))
         elona_repl:run()
      end

      return false, result
   end
end

local function test_file(file, filter_test_name, seed, debug_on_error)
   local chunk = assert(loadfile(file))
   local test_env, mt = make_test_env()

   setfenv(chunk, test_env)

   chunk()

   local failures = {}
   local total = 0

   for _, pair in ipairs(mt.__tests) do
      local name = pair[1]
      local test_fn = pair[2]

      if string.match(name, filter_test_name) then
         local success, result = run_test(name, test_fn, seed, debug_on_error)
         if not success then
            failures[#failures+1] = result
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

   local seed = args.seed or math.floor(socket.gettime())

   print("Seed: " .. seed)
   print("")

   local spl = string.split(args.filter, ":")
   local filter_file_name = spl[1]
   local filter_test_name = spl[2] or ".*"

   Log.debug("Test filter: %s:%s", filter_file_name, filter_test_name)

   local failures = {}
   local total = 0

   local function get_files(path)
      local items = fs.get_directory_items(path)
      local files = fun.iter(items):map(function(f) return fs.join(path, f) end):to_list()
      return files
   end
   local files = get_files("test/unit/")

   while #files > 0 do
      local path = files[#files]
      files[#files] = nil
      if fs.is_directory(path) then
         table.append(files, get_files(path))
      else
         if string.match(path, filter_file_name) then
            local failures_, total_ = test_file(path, filter_test_name, seed, args.debug_on_error)
            failures = table.append(failures, failures_)
            total = total + total_
         end
      end
   end

   cleanup_globals()

   print()
   if total == 0 then
      print(ansicolors("%{red}No tests matched the filter.%{reset}"))
      return 1
   elseif #failures > 0 then
      if not args.debug_on_error then
         for _, result in ipairs(failures) do
            print_result(result)
         end
      end
      print(ansicolors(("%%{red}%d/%d tests failed.%%{reset}"):format(#failures, total)))
      return #failures
   else
      print(ansicolors(("%%{green}%d tests passed.%%{reset}"):format(total)))
      return 0
   end
end
