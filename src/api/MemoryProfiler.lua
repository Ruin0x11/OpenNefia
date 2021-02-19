local Env = require("api.Env")
local Log = require("api.Log")
local MemoryProfiler = class.class("MemoryProfiler")

function MemoryProfiler:init(log_level, precision)
   self.count = collectgarbage("count")
   self.precision = precision or 2
   self.log_level = log_level or "info"
   self:measure()
end

function MemoryProfiler:measure()
   local new = collectgarbage("count")
   local result = new - self.count
   self.count = new
   return math.round(result, self.precision)
end

function MemoryProfiler:measure_and_format(text)
   if text then
      text = string.format("[%s]", text)
   else
      text = ""
   end

   local kbs = self:measure()
   return string.format("%s\t%02." .. string.format("%02d", self.precision) .. "fKB\t(%02.02fMB)", text, kbs, kbs / 1024)
end

function MemoryProfiler:p(text)
   Log[self.log_level](self:measure_and_format(text))
end

function MemoryProfiler:bench(f, ...)
   self:measure()
   f(...)
   return self:measure_and_format()
end

return MemoryProfiler
