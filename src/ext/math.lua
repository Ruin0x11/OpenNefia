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

--- Returns "integer" if x is an integer, "float" if it is a float, or nil if x is not a number.
---
--- Ported from 5.3.
--- @param x
--- @treturn string
function math.type(x)
   if type(x) ~= "number" then
      return nil
   end

   if math.floor(x) == x then
      return "integer"
   end

   return "float"
end

function math.map(n, a_min, a_max, b_min, b_max, bound)
   local new = (n - a_min) / (a_max - a_min) * (b_max - b_min) + b_min
   if not bound then
      return new
   end

   if b_min < b_max then
      return math.clamp(new, b_min, b_max)
   else
      return math.clamp(new, b_max, b_min)
   end
end
