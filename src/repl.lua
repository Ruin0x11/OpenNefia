_CONSOLE = true
require("boot")

require("internal.data.base")

local Stopwatch = require("api.Stopwatch")
local sw = Stopwatch:new()

local field_logic = require("game.field_logic")
local field = require("game.field")
local mod = require("internal.mod")
local env = require("internal.env")
local repl = require("internal.repl")
local data = require("internal.data")
local startup = require("game.startup")
local fs = require("util.fs")
local save = require("internal.global.save")
local ReplLayer = require("api.gui.menu.ReplLayer")
local Gui = require("api.Gui")
local Log = require("api.Log")

if not fs.exists(fs.get_save_directory()) then
   fs.create_directory(fs.get_save_directory())
end

Log.set_level("info")

local mods = mod.scan_mod_dir()
startup.run_all(mods)

local apis = repl.require_all_apis()
apis = table.merge(apis, repl.require_all_apis("internal"))
apis = table.merge(apis, repl.require_all_apis("game"))

for k, v in pairs(apis) do
   rawset(_G, k, v)
end

rawset(_G, "_PROMPT", "> ")
rawset(_G, "_PROMPT2", ">> ")
rawset(_G, "data", data)
rawset(_G, "h", env.hotload)
rawset(_G, "save", save)

local function pass_one_turn(turns)
   if not field.player then
      error("field not active")
   end

   turns = turns or 1
   local ev = "turn_begin"
   local target_chara, going

   local cb = function()
      for i=1,turns do
         Gui.mes(string.format("==== turn %d ====", i))
         repeat
            going, ev, target_chara = field_logic.run_one_event(ev, target_chara)
         until ev == "player_turn_query"

         ev = "turn_end"

         repeat
            going, ev, target_chara = field_logic.run_one_event(ev, target_chara)
         until ev == "turn_begin"
      end

      return going, ev, target_chara
   end

   local co = coroutine.create(cb)
   local ok, err = coroutine.resume(co, 0)
   if not ok or err ~= nil then
      if type(err) == "string" then
         error("\n\t" .. (err or "Unknown error."))
      end
   end
end

rawset(_G, "tu", pass_one_turn)

local function load_game()
   field.is_active = false
   field_logic.quickstart()
   field_logic.setup()
   field.is_active = true
   Gui.update_screen()
end

rawset(_G, "lo", load_game)

local function register_thirdparty_module(name)
   local paths = string.format("./thirdparty/%s/?.lua;./thirdparty/%s/?/init.lua", name, name)
   package.path = package.path .. ";" .. paths
end

register_thirdparty_module("repl")

if fs.exists("repl_startup.lua") then
   local chunk = loadfile("repl_startup.lua")
   setfenv(chunk, _G)
   chunk()
end


local console_repl = require("thirdparty.repl.console")
local elona_repl   = console_repl:clone()
local debug_server = require("internal.debug_server")

-- @see repl:showprompt(prompt)
function elona_repl:compilechunk(text)
   local chunk, err = loadstring("return " .. text)

   if chunk == nil then
      return console_repl:compilechunk(text)
   end

   return chunk, err
end

server = nil

-- @see repl:prompt(prompt)
function elona_repl:prompt(level)
   if server == nil or env.server_needs_restart then
      if server then
         server:stop()
      end
      server = debug_server:new()
      server:start()
      env.server_needs_restart = false
   end

   if not self.server_stepped then
      console_repl:prompt(level)
   end

   self.server_stepped = false
end

local super = elona_repl.handleline
function elona_repl:handleline(line)
   if line == "server:step()" then
      self.server_stepped = true
   end
   return super(self, line)
end

local function gather_results(success, ...)
   local n = select('#', ...)
   return success, { n = n, ... }
end

-- @see repl:displayresults(results)
function elona_repl:displayresults(results)
   if self.server_stepped then
      return
   end

   -- omit parens (elona console style)
   if results.n == 1 and type(results[1]) == "function" then
      local success
      success, results = gather_results(xpcall(results[1], function(...) return self:traceback(...) end))
      if not success then
         self:displayerror(results[1])
         return
      end
   end

   local result_text = ReplLayer.format_results(results, true)
   for line in string.lines(result_text) do
      if #line > 2500 then
         line = string.sub(line, 1, 2500) .. "..."
      end
      print(line)
   end
end

sw:p("REPL startup time")

if arg[1] == "test" then
   os.exit(0)
elseif arg[1] == "batch" then
   local chunk, err = loadfile(arg[2])
   assert(chunk, err)
   chunk()
   os.exit(0)
elseif arg[1] == "load" then
   lo()
end

local Env = require("api.Env")

print(string.format("Elona_next(仮 REPL\nVersion: %s  LÖVE version: %s  Lua version: %s  OS: %s",
                    Env.version(), Env.love_version(), Env.lua_version(), Env.os()))
elona_repl:run()
