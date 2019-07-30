local Rand = {}

function Rand.rnd(a, b)
   if b == nil then
      b = a
      a = 0
   end

   -- TODO: replace with same rng method as hsp
   -- TODO: alias math.random to this function
   return math.random(math.floor(a), math.floor(b) - 1)
end

function Rand.one_in(n)
   return Rand.rnd(n) == 0
end

function Rand.one_in_percent(n)
   return 100 / n
end

function Rand.set_seed(seed)
   math.randomseed(seed)
end

function Rand.choice(array)
   assert(type(array) == "table")
   local i = array[Rand.rnd(#array)+1]
   return i
end

function Rand.percent_chance(percent)
   return math.random() < (percent / 100)
end

function Rand.roll_dice(dice_x, dice_y, add)
   dice_x = math.max(dice_x, 1)
   dice_y = math.max(dice_y, 1)
   local result = 0
   for _ in fun.range(1, dice_x) do
      result = result + Rand.rnd(dice_y) + 1
   end
   return result + add
end

function Rand.dice_max(dice_x, dice_y, add)
   return dice_x * dice_y + add
end

return Rand
