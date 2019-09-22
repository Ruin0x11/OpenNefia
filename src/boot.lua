package.path = package.path .. ";./thirdparty/?.lua;./?/init.lua"

local dir_sep = package.config:sub(1,1)
local is_windows = dir_sep == "\\"

if love == nil then
   if is_windows then
      package.cpath = package.cpath .. ";..\\lib\\luautf8\\?.dll;..\\lib\\luasocket\\?.dll;..\\lib\\luafilesystem\\?.dll"
      package.path = package.path .. ";..\\lib\\luasocket\\?.lua"
   end

   _DEBUG = true
   love = require("util.lovemock")
end

-- globals that will be used very often.

_DEBUG = true

require("ext")

mobdebug = require("mobdebug")
mobdebug.is_running = function()
   local _, mask = debug.gethook(coroutine.running())
   return mask == "crl"
end
mobdebug.scope = function(f)
   local set = false
   if _DEBUG and mobdebug.is_running() then
      set = true
      mobdebug.off()
   end

   f()

   if set then
      mobdebug.on()
   end
end

inspect = require("thirdparty.inspect")
fun = require("thirdparty.fun")

class = require("util.class")

function _p(...)
   local t = {...}
   local max = 0

   -- nil values in varargs will mess up ipairs, so iterate by the
   -- largest array index found instead and assume everything in
   -- between was passed as nil.
   for k, _ in pairs(t) do
      max = math.max(max, k)
   end

   for i=1,max do
      local v = t[i]
      if v == nil then
         io.write("nil")
      else
         io.write(inspect(v))
      end
      io.write("\t")
   end
   if #{...} == 0 then
      io.write("nil")
   end
   io.write("\n")
   return ...
end

-- prevent new globals from here on out.
require("thirdparty.strict")

-- Hook the global `require` to support hotloading.
require("internal.env").hook_global_require()
