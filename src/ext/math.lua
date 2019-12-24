--- @module math

--- Clamps a number `i` between two numbers `min` and `max`.
---
--- @tparam number i
--- @tparam number min
--- @tparam number max
--- @treturn number
function math.clamp(i, min, max)
   return math.min(max, math.max(min, i))
end

function math.percent(v, per)
   return math.floor((per / 100) * v)
end

function math.percent_inc(v, per)
   return v + math.percent(v, per)
end

function math.percent_dec(v, per)
   return v - math.percent(v, per)
end

--- If `v` is negative, returns `-1`. Else, returns `1`.
---
--- @tparam number v
--- @treturn integer
function math.sign(v)
   return (v >= 0 and 1) or -1
end

--- Rounds a number to the specified number of digits.
---
--- @tparam number v
--- @tparam[opt] uint digits
--- @treturn number
function math.round(v, digits)
   digits = digits or 0
   local bracket = 1 / (10 ^ digits)
   return math.floor(v/bracket + math.sign(v) * 0.5) * bracket
end

-- Replace Lua's implementation of the RNG with the one from HSP.
local Rand = require("api.Rand")
math.random = function(n, m)
   if n and m then
      return Rand.between(n, m) + 1
   elseif n then
      return Rand.rnd(n) + 1
   end

   return Rand.rnd_float()
end
math.randomseed = Rand.set_seed
