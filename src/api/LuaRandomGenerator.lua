-- NOTE: This sets global state, so you can't instantiate two instances of this
-- class with differents states.

-- @module LuaRandomGenerator

local IRandomGenerator = require("api.IRandomGenerator")

local LuaRandomGenerator = class.class("LuaRandomGenerator", IRandomGenerator)
local socket = require("socket")

function LuaRandomGenerator:init(seed)
   self:set_seed(seed)
end

function LuaRandomGenerator:set_seed(seed)
   if seed == nil then
      seed = socket.gettime()
   end
   math.randomseed(seed)
end

function LuaRandomGenerator:rnd(n)
   return math.random(n) - 1
end

function LuaRandomGenerator:rnd_float()
   return math.random()
end

return LuaRandomGenerator
