_DEBUG = false
_CONSOLE = _CONSOLE or false

_IS_LOVEJS = jit == nil

package.path = package.path .. ";./thirdparty/?.lua;./?/init.lua;./?.fnl;./?/init.fnl"

local dir_sep = package.config:sub(1,1)
local is_windows = dir_sep == "\\"

if is_windows then
   package.path = package.path .. ";..\\lib\\luasocket\\?.lua;..\\lib\\lua-vips\\?.lua"
   package.cpath = package.cpath .. ";..\\lib\\luautf8\\?.dll;..\\lib\\luasocket\\?.dll;..\\lib\\luafilesystem\\?.dll"
else
   package.cpath = package.cpath .. ";../lib/?.so"
end

if love == nil then
   _CONSOLE = true

   love = require("util.lovemock")
end

-- BUG: LÖVE for Android will not load relative paths for some reason,
-- probably due to a PhysFS bug. Due to this we have to expand the
-- relative paths in package.path ourselves and use functions like
-- love.filesystem.load instead of loadfile to go through LÖVE's
-- filesystem abstraction layer so the files can be found.
if love.system.getOS() == "Android" then
   local absolute_dir = love.filesystem.getSource()
   package.path = package.path:gsub('%./', absolute_dir)
end

-- We have to update LÖVE's require path which is completely separate
-- from package.path in order to make love.filesystem.load work
-- properly
love.filesystem.setRequirePath(package.path)

local fennel = require("thirdparty.fennel")
table.insert(package.loaders or package.searchers, fennel.searcher)

-- globals that will be used very often.

if _DEBUG then
   _CONSOLE = true
end

class = require("util.class")

require("ext")

inspect = require("thirdparty.inspect")
fun = require("thirdparty.fun")

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
