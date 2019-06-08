local Rand = {}

function Rand.rnd(i)
   -- TODO: replace with same rng method as hsp
   -- TODO: alias math.random to this function
   return math.random(0, i - 1)
end

function Rand.one_in(n)
   return Rand.rnd(n) == 0
end

function Rand.coinflip()
   return Rand.rnd(2) == 0
end

function Rand.set_seed(seed)
   math.randomseed(seed)
end

function Rand.choice(array)
   if type(array) ~= "table" then return array end
   return array[Rand.rnd(#array)+1]
end

function Rand.percent_chance(percent)
   return Rand.rnd(100) < percent
end

return Rand
