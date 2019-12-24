local IRandomGenerator = class.interface("IRandomGenerator",
                       {
                          rnd = "function",
                          rnd_float = "function",
                          set_seed = "function"
                       })

function IRandomGenerator:rnd_between(n, m)
   m = m or n
   return self:rnd(n) + (m - n)
end

return IRandomGenerator
