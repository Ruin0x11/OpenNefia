--- Contains information about the OS and program.
--- @module Env

local socket = require("socket")
local env = require("internal.env")
local queue = require("util.queue")

local Env = {}

--- Returns the version of elona-next as a string.
---
--- @treturn string
function Env.version()
   return "0.0.1"
end

--- @treturn string
function Env.love_version()
   return love.getVersion()
end

--- Returns true if the game was started in headless/REPL mode.
---
--- @treturn bool
function Env.is_headless()
   return (not love) or Env.love_version() == "lovemock"
end

-- @function Env.is_hotloading
Env.is_hotloading = env.is_hotloading

-- @function Env.get_require_path
Env.get_require_path = env.get_require_path

-- @function Env.get_time
Env.get_time = socket.gettime

local time_begin = Env.get_time()

function Env.get_play_time(old_play_time)
   return old_play_time + Env.get_time() - time_begin
end

function Env.update_play_time(old_play_time)
   local new = (old_play_time or 0) + Env.get_time() - time_begin
   time_begin = Env.get_time()
   return new
end

local ui_results = queue:new()

function Env.push_ui_result(result)
   if not Env.is_headless() then
      error("This function can only be used in headless mode.")
   end
   ui_results:push(result)
end

function Env.pop_ui_result()
   if not Env.is_headless() then
      error("This function can only be used in headless mode.")
   end
   return ui_results:pop()
end

function Env.clear_ui_results()
   if not Env.is_headless() then
      error("This function can only be used in headless mode.")
   end
   ui_results = queue:new()
end

--- @treturn string
function Env.lua_version()
   if jit then
      return string.format("%s %s", jit.version, jit.arch)
   end

   return _VERSION
end

--- @treturn string
function Env.os()
   if not Env.is_headless() then
      return love.system.getOS()
   end

   local dir_sep = package.config:sub(1,1)
   local is_windows = dir_sep == "\\"

   if is_windows then
      return "Windows"
   else
      return "Unix"
   end
end

--- @treturn string
function Env.clipboard_text()
   return love.system.getClipboardText()
end

--- @tparam string text
function Env.set_clipboard_text(text)
   return love.system.setClipboardText(text)
end

--- Returns the real-world date as reported by the OS.
---
--- @tparam string format
--- @tparam number time
function Env.real_time(format, time)
   return os.date(format, time)
end

return Env
