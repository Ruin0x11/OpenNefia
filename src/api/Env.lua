local Env = {}

function Env.version()
   return "0.0.1"
end

function Env.love_version()
   return love.getVersion()
end

function Env.is_headless()
   return Env.love_version() == "lovemock"
end

local ui_result = {}

function Env.set_ui_result(result)
   if not Env.is_headless() then
      error("This function can only be used in headless mode.")
   end
   ui_result = result
end

function Env.ui_result()
   if not Env.is_headless() then
      error("This function can only be used in headless mode.")
   end
   local result = ui_result
   ui_result = {}
   return result
end

function Env.lua_version()
   if jit then
      return string.format("%s %s", jit.version, jit.arch)
   end

   return _VERSION
end

function Env.os()
   return love.system.getOS()
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
