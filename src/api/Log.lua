-- @module Log
local Log = {}

local function format(kind, s, ...)
   local out = string.format(s, ...)
   local trace = debug.getinfo(3, "S")
   local source = ""
   if trace then
      local file = trace.source:sub(2)
      local line = trace.linedefined
      source = string.format("%s:%d: ", file, line)
   end
   print(string.format("[%s] %s%s", kind, source, out))
end

function Log.info(s, ...)
   format("INFO", s, ...)
end

function Log.warn(s, ...)
   format("WARN", s, ...)
end

function Log.error(s, ...)
   format("ERROR", s, ...)
end

return Log
