--- from https://github.com/luc-tielen/lua-quickcheck/blob/master/lqc/generators/int.lua

local IGenerator = require("api.test.gen.IGenerator")
local Rand = require("api.Rand")

local IntGen = class.class("IntGen", IGenerator)

--- Helper function for picking a random integer, bounded by min and max.
-- @param min minimum value
-- @param max maximum value
-- @return function that can generate an integer (min <= int <= max)
function IntGen:pick_bounded(min, max)
  local function do_pick() return Rand.between(min, max) end
  return do_pick
end


--- Helper function for finding number closest to 0.
-- @param a number 1
-- @param b number 2
-- @return number closest to 0
local function find_closest_to_zero(a, b)
  return (math.abs(a) < math.abs(b)) and a or b
end


--- Helper function for shrinking integer, bounded by min and max. (min <= int <= max)
-- @param min minimum value
-- @param max maximum value
-- @return shrunk integer (shrinks towards 0 / closest value to 0 determined
--         by min and max)
function IntGen:shrink_bounded(min, max)
  local bound_limit = find_closest_to_zero(min, max)
  local function do_shrink(self, previous)
    if previous == 0 or previous == bound_limit then return {} end
    if previous > 0 then return { math.floor(previous / 2) } end
    return { math.ceil(previous / 2) }
  end
  return do_shrink
end


--- Picks a random integer, uniformy spread between +- sample_size / 2.
-- @param sample_size Number of times this generator is used in a property;
--                    used to guide the optimatization process.
-- @return random integer
function IntGen:pick_uniform(sample_size)
  local value = sample_size / 2
  return Rand.between(value - sample_size, value)
end


--- Shrinks an integer by dividing it by 2 and rounding towards 0.
-- @param previous previously generated integer value
-- @return shrunk down integer value
function IntGen:shrink(previous)
  if previous == 0 then return {} end
  if previous > 0 then return { math.floor(previous / 2) } end
  return { math.ceil(previous / 2) }
end

--- Creates a new integer generator.
-- @param nr1 number containing first bound
-- @param nr2 number containing second bound
-- @return generator that can generate integers according to the following strategy:
--   - nr1 and nr2 provided: nr1 <= int <= nr2
--   - only nr1 provided: 0 <= int <= max
--   - no bounds provided: -numtests/2 <= int <= numtests/2
function IntGen:init(nr1, nr2)
   if nr1 and nr2 then
      self.pick = self:pick_bounded(nr1, nr2)
      self.shrink = self:shrink_bounded(nr1, nr2)
   elseif nr1 then
      self.pick = self:pick_bounded(0, nr1)
      self.shrink = IntGen.shrink
   else
      self.pick = IntGen.pick_uniform
      self.shrink = IntGen.shrink
   end
end

return IntGen
