-- NOTE: This sets global state, so you can't instantiate two instances of this
-- class with differents states.

-- @module LuaRandomGenerator

local IRandomGenerator = require("api.IRandomGenerator")

local LuaRandomGenerator = class.class("LuaRandomGenerator", IRandomGenerator)
local socket = require("socket")
local config = require("internal.config")

function LuaRandomGenerator:init(seed)
   if seed == nil then
      seed = config["base.debug_random_seed"] or socket.gettime()
   end
   self:set_seed(seed)
end

function LuaRandomGenerator:set_seed(seed)
   math.randomseed(seed)
end

function LuaRandomGenerator:rnd(n)
   return math.random(n) - 1
end

function LuaRandomGenerator:rnd_float()
   return math.random()
end

return LuaRandomGenerator
