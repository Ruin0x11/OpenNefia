--- Implements the random generator from the HSP runtime. It's a
--- linear congruential generator.
-- @module RandomGenerator

local IRandomGenerator = require("api.IRandomGenerator")

local RandomGenerator = class.class("RandomGenerator", IRandomGenerator)
local socket = require("socket")
local config = require("internal.config")

function RandomGenerator:init(seed)
   self:set_seed(seed)
end

function RandomGenerator:set_seed(seed)
   if seed == nil then
      -- In OpenHSP on Windows this uses GetTickCount, on Unix it uses
      -- time(0).
      --
      -- https://github.com/onitama/OpenHSP/blob/1d3d134a5d12017a413cafe527768883fb85c8a1/src/hsp3/hsp3int.cpp#L1033
      seed = config["base.debug_random_seed"] or socket.gettime()
   end

   self.seed = seed
end

function RandomGenerator:rnd_huge(n)
   self.seed = (214013 * self.seed + 2531011) % 4294967296

   if n <= 0 then
      return 0
   end

   return math.floor(self.seed % n)
end

--- NOTE this function is for compatibility with HSP, where rnd() will not
--- return a value larger than 32768.
function RandomGenerator:rnd_small(n)
   self.seed = (214013 * self.seed + 2531011) % 4294967296

   if n <= 0 then
      return 0
   end

   return bit.band(bit.rshift(self.seed, 16), 0x7FFF) % n
end

function RandomGenerator:rnd(n)
   -- If we're trying to generate a large number, do not use HSP's legacy
   -- behavior and return a 64-bit value.
   if n > 0x7FFF then
      return self:rnd_huge(n)
   end

   -- Otherwise, behave exactly the same as HSP does. This is so a random seed
   -- will return the exact same values as it would in HSP so long as the
   -- largest random number limit is not exceeded.
   return self:rnd_small(n)
end

function RandomGenerator:rnd_float()
   self:rnd(0)
   return self.seed / 4294967296
end

return RandomGenerator
