--- @module Rand
local Rand = {}

--- Returns a random integer in `[0, n)`.
--- @tparam int n
--- @treturn int
function Rand.rnd(n)
   return math.random(0, math.floor(n) - 1)
end

--- Returns a random integer in `[a, b)`.
--- @tparam int a
--- @tparam int b
function Rand.between(a, b)
   return math.random(math.floor(a), math.floor(a+b) - 1)
end

--- Returns true one out of every `n` times.
---
--- @tparam int n
--- @treturn bool
function Rand.one_in(n)
   return Rand.rnd(n) == 0
end

function Rand.one_in_percent(n)
   return 100 / n
end

--- TODO: must be constant and unmodifiable, for determinism
function Rand.set_seed(seed)
   math.randomseed(seed)
end

-- Selects a random element out of an arraylike table or iterator. If
-- an iterator is passed it must be finite, or an infinite loop will
-- occur.
--
-- @tparam table|Iterator(any) arr_or_iter
-- @return any
function Rand.choice(arr_or_iter)
   local arr = arr_or_iter
   assert(type(arr_or_iter) == "table")
   if tostring(arr_or_iter) == "<generator>" then
      arr = arr_or_iter:to_list()

   end
   local i = arr[Rand.rnd(#arr)+1]
   return i
end

function Rand.percent_chance(percent)
   return math.random() < (percent / 100)
end

-- Rolls a die of (x)d(y) + add.
--
-- @tparam int dice_x
-- @tparam int dice_y
-- @tparam int add
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
