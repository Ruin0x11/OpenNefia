--- @module Rand
local LuaRandomGenerator = require("api.LuaRandomGenerator")
local HspRandomGenerator = require("api.HspRandomGenerator")

local Rand = {}

local rng_lua = LuaRandomGenerator:new()
local rng_hsp = HspRandomGenerator:new()
local rng = rng_lua

--- Returns a random integer in `[0, n)`.
---
--- @tparam int n
--- @treturn int
function Rand.rnd(n)
   return rng:rnd(math.floor(n))
end

--- Returns a random integer in `[n, m)`.
---
--- @tparam int n
--- @tparam int m
function Rand.between(n, m)
   return rng:rnd_between(math.floor(n), math.floor(m))
end

--- Returns a random float in `[0, 1)`.
--- @treturn number
function Rand.rnd_float()
   return rng:rnd_float()
end

--- Returns true one out of every `n` times.
--- @tparam int n
--- @treturn bool
function Rand.one_in(n)
   return Rand.rnd(n) == 0
end

function Rand.one_in_percent(n)
   return 100 / n
end

--- Sets the seed of the random generator, like HSP's `randomize` function. Pass
--- in `nil` to set the seed to the current time.
---
--- @tparam[opt] int seed
--- @tparam[opt] string rng_kind "lua" (default), "hsp"
function Rand.set_seed(seed, rng_kind)
   rng_lua:set_seed(seed)
   rng_hsp:set_seed(seed)
   if rng_kind == "hsp" then
      rng = rng_hsp
   elseif rng_kind == "lua" or rng_kind == nil then
      rng = rng_lua
   else
      error(("Invalid RNG type '%s'"):format(rng_kind))
   end
end

-- Selects a random element out of an arraylike table or iterator. If
-- an iterator is passed it must be finite, or an infinite loop will
-- occur.
--
-- @tparam table|Iterator(any) arr_or_iter
-- @return any
function Rand.choice(arr_or_iter)
   local arr = arr_or_iter
   assert(type(arr_or_iter) == "table", "Rand.choice must be passed a table, got " .. type(arr_or_iter))
   if tostring(arr_or_iter) == "<generator>" then
      arr = arr_or_iter:to_list()
   end
   if #arr == 0 then
      return nil
   end
   return arr[Rand.rnd(#arr)+1]
end

function Rand.percent_chance(percent)
   return rng:rnd_float() < (percent / 100)
end

-- Rolls a die of <x>d<y> + <add>
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

-- Returns the maximum roll possible from a die of <x>d<y> + <add>
--
-- @tparam int dice_x
-- @tparam int dice_y
-- @tparam int add
function Rand.dice_max(dice_x, dice_y, add)
   return dice_x * dice_y + add
end

-- Randomly shuffles the elements of a table. Returns a new table.
--
-- @tparam table tbl immutable
-- @tparam table res
function Rand.shuffle(tbl)
   for i=1, #tbl do
      local j = Rand.rnd(#tbl-i+1) + i
      local tmp = tbl[j]
      tbl[j] = tbl[i]
      tbl[i] = tmp
   end
end

return Rand
