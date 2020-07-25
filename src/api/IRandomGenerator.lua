local IRandomGenerator = class.interface("IRandomGenerator",
                       {
                          rnd = "function",
                          rnd_float = "function",
                          set_seed = "function"
                       })

function IRandomGenerator:rnd_between(min, max)
   max = max or min
   return min + self:rnd(max - min)
end

return IRandomGenerator
