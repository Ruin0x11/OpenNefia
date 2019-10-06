local queue = require("util.queue")

local Env = {}

function Env.version()
   return "0.0.1"
end

function Env.love_version()
   return love.getVersion()
end

function Env.is_headless()
   return (not love) or Env.love_version() == "lovemock"
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

function Env.lua_version()
   if jit then
      return string.format("%s %s", jit.version, jit.arch)
   end

   return _VERSION
end

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

function Env.clipboard_text()
   return love.system.getClipboardText()
end

function Env.set_clipboard_text(text)
   return love.system.setClipboardText(text)
end

function Env.real_time(format, time)
   return os.date(format, time)
end

return Env
