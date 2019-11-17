local env = require("internal.env")
local IReplMode = require("api.gui.menu.IReplMode")

local LuaReplMode = class.class("LuaReplMode", IReplMode)

function LuaReplMode:init(mod_env)
   self.caret = "> "
   self.env = mod_env
end

local function push_history(env, result)
   local max = 10
   for i = max-1, 1 do
      -- push the most recent result and shift the rest down
      -- _1 -> _2
      local id = "_" .. tostring(i)
      local next_id = "_" .. tostring(i+1)
      if env[id] then
         env[next_id] = env[id]
         env[id] = nil
      end
   end
   env["_1"] = result
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

   -- capture (status, varags...) as a table
   local results = { xpcall(chunk, function(err) return debug.traceback(err, 2) end) }

   local ok = results[1]

   if ok then
      push_history(self.env, results[2])
   end

   table.remove(results, 1)
   return ok, results
end

return LuaReplMode
