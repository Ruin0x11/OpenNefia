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
local Stopwatch = require("api.Stopwatch")
local TestUtil = require("api.test.TestUtil")
local Advice = require("api.Advice")
local main_state = require("internal.global.main_state")
local Env = require("api.Env")
local aspect_state = require("internal.global.aspect_state")
local mod_info = require("internal.mod_info")

local function reset_all_globals()
   Log.debug("Resetting global state.")
   startup.reset_all_globals()

   -- Now we need to make sure that the chunks loaded by main.lua will get
   -- loaded again, causing all the global state chunks to be reloaded too.
   require("internal.data.base")

   -- Finally, we need to reload the module references in this file because
   -- package.loaded was cleared.
   field = require("game.field")
   mod = require("internal.mod")
   startup = require("game.startup")
   fs = require("util.fs")
   Event = require("api.Event")
   env = require("internal.env")
   socket = require("socket")
   Rand = require("api.Rand")
   elona_repl = require("internal.elona_repl")
   Repl = require("api.Repl")
   ansicolors = require("thirdparty.ansicolors")
   Log = require("api.Log")
   config_store = require("internal.config_store")
   save_store = require("internal.save_store")
   SaveFs = require("api.SaveFs")
   Stopwatch = require("api.Stopwatch")
   TestUtil = require("api.test.TestUtil")
   Advice = require("api.Advice")
   main_state = require("internal.global.main_state")
   Env = require("api.Env")
end

-- Make an environment rejecting the setting of global variables except
-- functions that are named "test_*".
local function make_test_env()
   local tests = env.generate_sandbox(TestUtil.TEST_MOD_ID)
   tests.require = require
   tests.getmetatable = getmetatable
   tests.setmetatable = setmetatable
   tests.rawget = setmetatable
   tests.rawset = setmetatable

   local disabled = false
   tests.disable = function(reason)
      assert(type(reason) == "string", "Must provide reason for disabling test")
      disabled = true
   end

   local mt = { __tests = {}, __declared = {} }

   function mt.__newindex(t, k, v)
      if type(k) == "string" and string.match(k, "^test_") and type(v) == "function" then
         table.insert(mt.__tests, {name=k, test_fn=v, disabled=disabled})
         rawset(t, k, v)
         disabled = false
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

local function load_test_mod()
   -- TODO this will have its own manifest loaded "virtually" at some point
   main_state.loaded_mods[TestUtil.TEST_MOD_ID] = true
end

local function cleanup_globals()
   config_store.clear()
   save_store.clear()
   fs.remove(fs.parent(SaveFs.save_path("", "save", TestUtil.TEST_SAVE_ID)))
   fs.remove(SaveFs.save_path("", "temp"))
   fs.remove(SaveFs.save_path("", "global"))
   field:init_global_data()
   Advice.remove_by_mod(TestUtil.TEST_MOD_ID)
   table.replace_with(aspect_state.default_impls, {})
   Env.clear_ui_results()
   env.unload_transient_paths()

   config_store.proxy().base.autosave = "almost_never"
end

local function print_result(result)
   io.write(ansicolors("%{red}\nFailure: " .. result.test_name .. "\n"))
   io.write(ansicolors("============(traceback)\n%{reset}" .. tostring(result.traceback) .. "\n"))
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
   print = function(...) for _, i in ipairs({...}) do redir_out:write(tostring(i) .. "\t"); end redir_out:write("\n") end

      local ok, err = xpcall(test_fn, capture)

      print = _print

      if ok then
         io.write(ansicolors("%{green}.%{reset}"))
         io.flush()
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

         io.flush()

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
   local disabled = 0

   for _, entry in ipairs(mt.__tests) do
      local name = entry.name
      local test_fn = entry.test_fn
      local is_disabled = entry.disabled

      if is_disabled then
         io.write(ansicolors("%{yellow}D%{reset}"))
         io.flush()
         disabled = disabled + 1
      elseif string.match(name, filter_test_name) then
         local success, result = run_test(name, test_fn, seed, debug_on_error)
         if not success then
            failures[#failures+1] = result
         end
         total = total + 1
      end
   end

   return failures, total, disabled
end

return function(args)
   if not fs.exists(fs.get_save_directory()) then
      fs.create_directory(fs.get_save_directory())
   end

   local failures = {}
   local total = 0
   local disabled = 0

   local sw = Stopwatch:new()


   local spl = string.split(args.filter, ":")
   local filter_mod_name = spl[1]
   local filter_file_name = spl[2] or ".*"
   local filter_test_name = spl[3] or ".*"

   Log.debug("Test filter: %s:%s", filter_file_name, filter_test_name)

   local all_mods = mod_info.scan_mod_dir()
   local mods_with_tests = {}

   if filter_mod_name ~= "@base@" then
      for _, mod_info in ipairs(all_mods) do
         local tests_dir = fs.join(mod_info.root_path, "test")
         if fs.exists(tests_dir) and mod_info.id:match(filter_mod_name) then
            table.insert(mods_with_tests, mod_info)
         end
      end
   end

   if #mods_with_tests > 0 then
      mods_with_tests = mod_info.calculate_load_order(mods_with_tests)

      local mod_names = table.concat(fun.iter(mods_with_tests):extract("id"):to_list(), ", ")

      print(("Test suites found: %d (%s)"):format(#mods_with_tests, mod_names))
      print()
   end

   local seed = args.seed or math.floor(socket.gettime())
   print("Seed: " .. seed)

   local last_mods = nil

   local function run_tests(tests_dir, enabled_mods, message)
      print()
      print(("===== Running %s... ====="):format(message))
      print()

      enabled_mods = table.keys(table.set(enabled_mods))
      table.sort(enabled_mods)

      -- Only reset the global state if the list of mods to load changes.
      if not table.deepcompare(last_mods, enabled_mods) then
         reset_all_globals()

         local mods = mod_info.scan_mod_dir(enabled_mods)
         startup.run_all(mods)

         load_test_mod()

         Event.trigger("base.on_startup")
         field:init_global_data()

         last_mods = enabled_mods
      end

      print()

      local function get_files(path)
         local items = fs.get_directory_items(path)
         local files = fun.iter(items):map(function(f) return fs.join(path, f) end):to_list()
         table.sort(files)
         return files
      end
      local files = get_files(tests_dir)

      while #files > 0 do
         local path = files[#files]
         files[#files] = nil
         if fs.is_directory(path) then
            table.append(files, get_files(path))
         else
            if string.match(path, filter_file_name) then
               local failures_, total_, disabled_ = test_file(path, filter_test_name, seed, args.debug_on_error)
               failures = table.append(failures, failures_)
               total = total + total_
               disabled = disabled + disabled_
            end
         end
      end

      cleanup_globals()

      print()
   end

   local base_mods = { "base", "elona_sys", "elona", "extlibs" }

   -- Base engine tests, under src/test.
   if filter_mod_name == "@base@" or filter_mod_name == ".*" then
      run_tests("test", base_mods, "base engine tests")
   end

   for _, mod_info in ipairs(mods_with_tests) do
      local tests_dir = fs.join(mod_info.root_path, "test")

      local deps = table.deepcopy(base_mods)
      deps[#deps+1] = mod_info.id

      run_tests(tests_dir, deps, ("tests for mod '%s'"):format(mod_info.id))
   end

   print("\n")

   local seconds_elapsed = sw:measure() / 1000
   print(("Finished in %02.08fs."):format(seconds_elapsed))
   print()

   if disabled > 0 then
      print(ansicolors(("%%{yellow}%d tests disabled.%%{reset}"):format(disabled, total)))
   end

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
