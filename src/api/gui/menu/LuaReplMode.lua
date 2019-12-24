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

-- Trims the trackback to remove unnecessary source locations at and
-- above the REPL logic itself.
local function trim_traceback(err)
   local trace = debug.traceback(err, 2)
   local new = ""

   for v in string.lines(trace) do
      if string.match(v, "^\t%[C%]: in function 'xpcall'$") then
         break
      end

      new = new .. v .. "\n"
   end

   return new
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
   print("get", getfenv(chunk).Tools)

   -- capture (status, varags...) as a table
   local results = { xpcall(chunk, trim_traceback) }

   local ok = results[1]

   if ok then
      push_history(self.env, results[2])
   else
      results[2] = "[Error]: " .. results[2]
   end

   -- Deal with nil values, since `table.remove`` will not shift down
   -- anything past a 'nil' in the middle of the result array.
   local max = 0
   for k, _ in pairs(results) do
      max = math.max(max, k)
   end
   for i=2,max do
      results[i-1] = results[i]
   end
   results.n = max - 1

   return ok, results
end

return LuaReplMode
