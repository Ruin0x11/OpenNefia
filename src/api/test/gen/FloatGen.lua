-- from https://github.com/luc-tielen/lua-quickcheck/blob/master/lqc/generators/float.lua

local IGenerator = require("api.test.gen.IGenerator")
local Rand = require("api.Rand")

local FloatGen = class.class("FloatGen", IGenerator)

--- Creates a generator for float values
-- @return a generator that can generate float values.
function FloatGen:init()
end

-- Generates a random float.
-- @param numtests Number of times this generator is called in a test; used to
--                 guide the randomization process.
-- @return random float (between - numtests / 2 and numtests / 2).
function FloatGen:pick(numtests)
  local lower_bound = - numtests / 2
  local upper_bound = numtests / 2
  return lower_bound + Rand.rnd_float() * (upper_bound - lower_bound)
end

--- Shrinks a float to a simpler value
-- @param prev a previously generated float value
-- @return shrunk down float value
function FloatGen:shrink(prev)
   if prev < 0.0000000001 then
      return {}
   end
   return { prev / 2 }
end

return FloatGen
