-- from https://github.com/luc-tielen/lua-quickcheck/blob/master/lqc/generators/bool.lua

local IGenerator = require("api.test.gen.IGenerator")
local Rand = require("api.Rand")

local BooleanGen = class.class("BooleanGen", IGenerator)

--- Creates a new bool generator
-- @return A generator object for randomly generating bools.
function BooleanGen:init()
end

--- Picks a random bool
-- @return true or false
function BooleanGen:pick(_)
  return Rand.one_in(2)
end

--- Shrinks down a bool (always shrinks to false)
function BooleanGen:shrink(_)
  return false
end

return BooleanGen
