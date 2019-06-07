package.path = package.path .. ";./thirdparty/?.lua;./?/init.lua"

-- globals that will be used very often.

_DEBUG = false

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

inspect = require("inspect")

local class_ = require("util.class")
interface = class_.interface
class = class_.class

if not love then
   _DEBUG = true
   love = require("util.lovemock")
end

function _p(it)
   print(inspect(it))
   return it
end

-- prevent new globals from here on out.
require("thirdparty.strict")
