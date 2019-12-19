_DEBUG = false
_CONSOLE = _CONSOLE or false

_IS_LOVEJS = jit == nil

package.path = package.path .. ";./thirdparty/?.lua;./?/init.lua;./?.fnl;./?/init.fnl"

local dir_sep = package.config:sub(1,1)
local is_windows = dir_sep == "\\"

if love == nil then
   if is_windows then
      package.cpath = package.cpath .. ";..\\lib\\luautf8\\?.dll;..\\lib\\luasocket\\?.dll;..\\lib\\luafilesystem\\?.dll"
      package.path = package.path .. ";..\\lib\\luasocket\\?.lua"
   end

   _CONSOLE = true

   love = require("util.lovemock")
end

-- globals that will be used very often.

if _DEBUG then
   _CONSOLE = true
end

require("ext")

inspect = require("thirdparty.inspect")
fun = require("thirdparty.fun")

class = require("util.class")

local function remove_all_metatables(item, path)
  if path[#path] ~= inspect.METATABLE then return item end
end

function _ppr(...)
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
         io.write(inspect(v, {process = remove_all_metatables}))
      end
      io.write("\t")
   end
   if #{...} == 0 then
      io.write("nil")
   end
   io.write("\n")
   return ...
end

if is_windows then
   -- Do not buffer stdout for Emacs compatibility.
   -- Requires LOVE's source to be modified to use stdin/stdout pipes
   -- on Windows.
   io.stdout:setvbuf("no")
   io.stderr:setvbuf("no")
end

-- prevent new globals from here on out.
require("thirdparty.strict")

if _IS_LOVEJS then
   -- hack to satisfy strict.lua
   jit = nil

   require("api.Log").set_level("debug")
end

-- Hook the global `require` to support hotloading.
require("internal.env").hook_global_require()
