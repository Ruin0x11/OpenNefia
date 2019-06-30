local env = require("internal.env")
local IReplMode = require("api.gui.menu.IReplMode")

local LuaReplMode = class.class("LuaReplMode", IReplMode)

function LuaReplMode:init(mod_env)
   self.caret = "> "
   self.env = mod_env

   self.env.hotload = env.hotload

   -- HACK
   self.env.Tools = env.safe_require("mod.tools.api.Tools")
   self.env.Dialog = env.safe_require("mod.elona_sys.dialog.api.Dialog")
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
