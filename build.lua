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

local fs = require("util.fs")
local preprocess = require("tools/preprocess")

preprocess("deps\\elona", "src\\mod\\elona")

assert(fs.copy_directory("deps/elona/sound", "src/mod/elona"))
