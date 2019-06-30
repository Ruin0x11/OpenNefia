local Env = {}

function Env.version()
   return "0.0.1"
end

function Env.love_version()
   return love.getVersion()
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

return Env
