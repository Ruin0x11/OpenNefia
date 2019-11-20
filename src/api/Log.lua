-- @module Log
local Log = {}

local levels = {
   trace = 5,
   debug = 4,
   info = 3,
   warn = 2,
   error = 1
}

local function format(kind, s, ...)
   local out = string.format(s, ...)
   local trace = debug.getinfo(3, "S")
   local source = ""
   if trace then
      local file = trace.source:sub(2)
      local line = trace.linedefined
      -- source = string.format("%s:%d: ", file, line)
   end
   print(string.format("%s %s%s", kind, source, out))
end

local level = levels.info

--- @tparam string l
function Log.set_level(l)
   if type(l) == "string" then
      l = levels[l] or 3
   end
   level = l
end

--- @tparam string l
function Log.has_level(l)
   if type(l) == "string" then
      l = levels[l] or 3
   end
   return level >= l
end

--- @tparam string s Format string for string.format
--- @param ...
function Log.trace(s, ...)
   if level < 5 then
      return
   end
   format("[TRACE]", s, ...)
end

--- @tparam string s Format string for string.format
--- @param ...
function Log.debug(s, ...)
   if level < 4 then
      return
   end
   format("[DEBUG]", s, ...)
end

--- @tparam string s Format string for string.format
--- @param ...
function Log.info(s, ...)
   if level < 3 then
      return
   end
   format("[INFO] ", s, ...)
end

--- @tparam string s Format string for string.format
--- @param ...
function Log.warn(s, ...)
   if level < 2 then
      return
   end
   format("[WARN] ", s, ...)
end

--- @tparam string s Format string for string.format
--- @param ...
function Log.error(s, ...)
   if level < 1 then
      return
   end
   format("[ERROR]", s, ...)
end

return Log
