require("boot")

require("internal.data.base")

local field_logic = require("game.field_logic")
local mod = require("internal.mod")
local env = require("internal.env")
local data = require("internal.data")
local startup = require("game.startup")
local fs = require("internal.fs")

local mods = mod.scan_mod_dir()
startup.run(mods)

field_logic.quickstart()

local apis = env.require_all_apis()
apis = table.merge(apis, env.require_all_apis("internal"))
apis = table.merge(apis, env.require_all_apis("game"))

for k, v in pairs(apis) do
   rawset(_G, k, v)
end

rawset(_G, "_PROMPT", "> ")
rawset(_G, "_PROMPT2", ">> ")
rawset(_G, "data", data)

if fs.exists("repl_startup.lua") then
   local chunk = loadfile("repl_startup.lua")
   setfenv(chunk, _G)
   chunk()
   print("OK")
end
