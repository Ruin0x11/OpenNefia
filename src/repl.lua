require("boot")

require("internal.data.base")

local field_logic = require("game.field_logic")
local mod = require("internal.mod")
local env = require("internal.env")
local data = require("internal.data")
local startup = require("game.startup")
local fs = require("util.fs")
local save = require("internal.global.save")

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

local function register_thirdparty_module(name)
   local paths = string.format("./thirdparty/%s/?.lua;./thirdparty/%s/?/init.lua", name, name)
   package.path = package.path .. ";" .. paths
end

register_thirdparty_module("repl")
register_thirdparty_module("yalf")

if fs.exists("repl_startup.lua") then
   local chunk = loadfile("repl_startup.lua")
   setfenv(chunk, _G)
   chunk()
   print("OK")
end

-- local repl = require("thirdparty.repl.console")
-- print("Lua REPL " .. tostring(repl.VERSION))
-- repl:run()
