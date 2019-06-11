local IReplMode = require("api.gui.menu.IReplMode")

local LuaReplMode = class("LuaReplMode", IReplMode)

function LuaReplMode:init(env)
   self.caret = "> "
   self.env = env

   -- HACK
   self.env.Debug = require("mod.debug.api.Debug")
   self.env.Tools = require("mod.tools.api.Tools")
end

function LuaReplMode:submit(text)
   -- WARNING: massive backdoor waiting to happen.
   local chunk, err = loadstring("return " .. text)

   if chunk == nil then
      chunk, err = loadstring(text)

      if chunk == nil then
         return false, err
      end
   end

   setfenv(chunk, self.env)

   local success, result = xpcall(chunk, function(err) return debug.traceback(err, 2) end)

   return success, result
end

return LuaReplMode
