--- @module Rand
local Rand = {}

--- Returns a random integer in `[0, n)`.
--- @tparam int n
function Rand.rnd(n)
   return math.random(0, math.floor(n) - 1)
end

--- Returns a random integer in `[a, b)`.
--- @tparam int a
--- @tparam int b
function Rand.between(a, b)
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
   if tostring(array) == "<generator>" then
      array = array:to_list()

   end
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

function Rand.shuffle(tbl)
   local res = table.deepcopy(tbl)

   for i=1, #res do
      local j = Rand.rnd(#res-i+1) + i
      local tmp = res[j]
      res[j] = res[i]
      res[i] = tmp
   end

   return res
end

return Rand
