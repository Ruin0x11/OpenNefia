local ffi = require "ffi"

-- Use versioned dependencies on Windows
if ffi.os == "Windows" then
   package.path = package.path .. ";.\\src\\?.lua;.\\lib\\lua-vips\\?.lua;.\\lib\\luasocket\\?.lua"
   package.cpath = package.cpath .. ";.\\lib\\luafilesystem\\?.dll;.\\lib\\luasocket\\?.dll"
else
   package.path = package.path .. ";./src/?.lua"

   local function check_dependency(name)
      local s, err = pcall(function() return require(name) end)
      if not s then
         error(string.format("Lua dependency '%s' not installed; use luarocks or similar to install it\nSee README.md for required libraries.\n%s", name, err))
      end
   end
   check_dependency("lfs")
   check_dependency("vips")
   check_dependency("socket")
end

local usage = [[
usage: luajit build.lua <command>
  preprocess: extract assets from vanilla Elona
  ldoc: run ldoc on source]]

local commands = {}

function commands.preprocess()
   local fs = require("util.fs")
   local preprocess = require("tools/preprocess")

   preprocess("deps\\elona", "src\\mod\\elona")

   assert(fs.copy_directory("deps/elona/sound", "src/mod/elona"))

   return 0
end

function commands.ldoc()
   local ret = os.execute("ldoc -i -c doc/config.ld . --fatalwarnings")
   if ret ~= 0 then return 1 end
   return 0
end

local command = arg[1] or ""
local cb = commands[command]

if cb == nil then
   print(usage)
   os.exit(1)
end

os.exit(cb())
