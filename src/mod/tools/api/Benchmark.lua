local Stopwatch = require("api.Stopwatch")

local Benchmark = {}

function Benchmark.run(cb, runs, ...)
   runs = runs or 200
   local sw = Stopwatch:new()
   local indiv = {}
   for i=1,runs do
      cb(...)
      indiv[#indiv + 1] = sw:measure()
   end

   local avg = 0
   for _, v in ipairs(indiv) do
      avg = avg + v
   end

   avg = avg / runs

   return {
      average = avg,
      runs = indiv
   }
end

return Benchmark
