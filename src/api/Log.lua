-- @module Log
local Log = {}

function Log.info(s, ...)
   local out = string.format(s, ...)
   print(string.format("[INFO]  %s", out))
end

function Log.warn(s, ...)
   local out = string.format(s, ...)
   print(string.format("[WARN]  %s", out))
end

function Log.error(s, ...)
   local out = string.format(s, ...)
   print(string.format("[ERROR] %s", out))
end

return Log
