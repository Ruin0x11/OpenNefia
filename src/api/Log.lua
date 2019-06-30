-- @module Log
local Log = {}

local function format(kind, s, ...)
   local out = string.format(s, ...)
   local trace = debug.getinfo(3, "S")
   local source = ""
   if trace then
      local file = trace.source:sub(2)
      local line = trace.linedefined
      -- source = string.format("%s:%d: ", file, line)
   end
   print(string.format("[%s] %s%s", kind, source, out))
end

local level = 3

function Log.set_level(l)
   level = l
end

function Log.trace(s, ...)
   if level < 5 then
      return
   end
   format("TRACE", s, ...)
end

function Log.debug(s, ...)
   if level < 4 then
      return
   end
   format("DEBUG", s, ...)
end

function Log.info(s, ...)
   if level < 3 then
      return
   end
   format("INFO", s, ...)
end

function Log.warn(s, ...)
   if level < 2 then
      return
   end
   format("WARN", s, ...)
end

function Log.error(s, ...)
   if level < 1 then
      return
   end
   format("ERROR", s, ...)
end

return Log
