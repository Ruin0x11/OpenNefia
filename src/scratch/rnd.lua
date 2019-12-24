local RandomGenerator = require("api.RandomGenerator")

local rng = RandomGenerator:new(100000)

local function randgen(m, a, c, seed)
   local seed = seed
   return function(i)
      seed = (a * seed + c) % m
      return bit.band(bit.rshift(seed, 16), 0x7FFF) % i
   end
end

local rand = randgen(4294967296, 214013, 2531011, 100000)

local want = {
   31684,
   25190,
   25328,
   15730,
   27961,
   25840,
   23001,
   21341,
   22727,
   17055,
   26372,
   9085,
}

local Rand = require("api.Rand")
Rand.set_seed(100000)

print("class","lcg","want")
print("---------------------")
for i= 1, 200 do
   print(Rand.rnd(100000), rng:rnd(100000), rand(100000), want[i])
end
