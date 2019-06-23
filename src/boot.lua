package.path = package.path .. ";./thirdparty/?.lua;./?/init.lua"

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

local class_ = require("util.class")
interface = class_.interface
class = class_.class

if love ~= nil then
   IS_LOVE = true
else
   _DEBUG = true
   IS_LOVE = false
   love = require("util.lovemock")
end

function _p(...)
   for _, v in ipairs({...}) do
      io.write(inspect(v))
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
