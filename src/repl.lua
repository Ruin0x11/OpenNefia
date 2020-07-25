---
--- This file is a separate entrypoint for running the game headlessly (without
--- LÖVE, under stock LuaJIT).
---

_CONSOLE = true
require("boot")

local Log = require("api.Log")
local level = "warn"
if arg[1] == "test" then
   level = "error"
end
Log.set_level(level)

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
local Event = require("api.Event")
local Gui = require("api.Gui")

if not fs.exists(fs.get_save_directory()) then
   fs.create_directory(fs.get_save_directory())
end

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
   Gui.update_screen() -- refresh shadows/FOV
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

sw:p("REPL startup time")

Event.trigger("base.on_startup")
field:init_global_data()

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
local elona_repl = require("internal.elona_repl")

print(string.format("OpenNefia REPL\nVersion: %s  LÖVE version: %s  Lua version: %s  OS: %s",
                    Env.version(), Env.love_version(), Env.lua_version(), Env.os()))
elona_repl:run()
