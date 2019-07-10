local env = require("internal.env")
local IReplMode = require("api.gui.menu.IReplMode")

local LuaReplMode = class.class("LuaReplMode", IReplMode)

function LuaReplMode:init(mod_env)
   self.caret = "> "
   self.env = mod_env
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

   self.env._1 = result

   return success, result
end

return LuaReplMode
