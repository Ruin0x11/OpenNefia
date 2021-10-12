--- Contains information about the OS and program.
--- @module Env

local socket = require("socket")
local env = require("internal.env")
local Queue = require("api.Queue")
local mod = require("internal.mod")
local API_VERSION = require("internal.global.api_version")

local Env = {}

function Env.commit_hash()
   local ok, commit = pcall(require, "internal.global.__COMMIT__")
   if ok then
      return commit
   end

   return "(unknown)"
end

--- Returns the current version of OpenNefia's API as an integer.
---
--- @treturn uint
function Env.api_version()
   return API_VERSION
end

--- Returns the version of OpenNefia as a formatted string, for printing
--- purposes.
---
--- @treturn string
function Env.version()
   local version_string = ("%d"):format(API_VERSION)
   local commit = Env.commit_hash()
   if commit then
      version_string = ("%s (%s)"):format(version_string, commit)
   end
   return version_string
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

-- @function Env.get_require_path
Env.get_module_of_member = env.get_module_of_member

-- @function Env.get_time
Env.get_time = socket.gettime

-- @function Env.is_valid_ident
Env.is_valid_ident = env.is_valid_ident

-- @function Env.assert_is_valid_ident
Env.assert_is_valid_ident = env.assert_is_valid_ident

-- @function Env.get_loaded_module_paths
Env.get_loaded_module_paths = env.get_loaded_module_paths

local time_begin = Env.get_time()

function Env.get_play_time(old_play_time)
   return old_play_time + Env.get_time() - time_begin
end

function Env.update_play_time(old_play_time)
   local new = (old_play_time or 0) + Env.get_time() - time_begin
   time_begin = Env.get_time()
   return new
end

local ui_results = Queue:new()

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
   local result = ui_results:pop()
   if result == nil then
      return nil
   end
   return table.unpack(result)
end

function Env.clear_ui_results()
   if not Env.is_headless() then
      error("This function can only be used in headless mode.")
   end
   ui_results = Queue:new()
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

--- @tparam string mod_id
--- @treturn boolean
function Env.is_mod_loaded(mod_id)
   return mod.is_loaded(mod_id)
end

--- Returns a filter to be used with data[_type]:iter():filter(filter) matching
--- on entries originating from the mod `mod_id`.
function Env.mod_filter(mod_id)
   local regex = ("^%s%%."):format(mod_id)
   return function(entry)
      return entry._id:match(regex)
   end
end

function Env.iter_mods()
   return mod.iter_loaded():extract("id")
end

return Env
