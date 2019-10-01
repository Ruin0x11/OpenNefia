local Log = require("api.Log")
Log.set_level("debug")

require("boot")

require("internal.data.base")

local field_logic = require("game.field_logic")
local mod = require("internal.mod")
local env = require("internal.env")
local data = require("internal.data")
local startup = require("game.startup")
local fs = require("util.fs")
local save = require("internal.global.save")
local ReplLayer = require("api.gui.menu.ReplLayer")

local mods = mod.scan_mod_dir()
startup.run(mods)

local apis = env.require_all_apis()
apis = table.merge(apis, env.require_all_apis("internal"))
apis = table.merge(apis, env.require_all_apis("game"))

for k, v in pairs(apis) do
   rawset(_G, k, v)
end

rawset(_G, "_PROMPT", "> ")
rawset(_G, "_PROMPT2", ">> ")
rawset(_G, "data", data)
rawset(_G, "hotload", env.hotload)
rawset(_G, "h", env.hotload)
rawset(_G, "load_game", field_logic.quickstart)
rawset(_G, "save", save)

local function pass_one_turn(turns)
   if not field.player then
      error("field not active")
   end

   turns = turns or 1
   local ev = "turn_begin"
   local target_chara, going

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

rawset(_G, "turn", pass_one_turn)

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


print("===================")
local console_repl = require 'thirdparty.repl.console'
local elona_repl   = console_repl:clone()

-- @see repl:showprompt(prompt)
function elona_repl:compilechunk(text)
   local chunk, err = loadstring("return " .. text)

   if chunk == nil then
      return console_repl:compilechunk(text)
   end

   return chunk, err
end

-- @see repl:displayresults(results)
function elona_repl:displayresults(results)
   local result_text = ReplLayer.format_results(results)
   for line in string.lines(result_text) do
      if #line > 2500 then
         line = string.sub(line, 1, 2500) .. "..."
      end
      print(line)
   end
end

if arg[1] == "test" then
   os.exit(0)
end

local Env = require("api.Env")

print(string.format("Elona_next(仮 REPL\nVersion: %s  LÖVE version: %s  Lua version: %s  OS: %s",
                    Env.version(), Env.love_version(), Env.lua_version(), Env.os()))
elona_repl:run()
