local Stopwatch = require("api.Stopwatch")
local config = require("internal.config")
local Rand = require("api.Rand")
local socket = require("socket")

local QuickCheck = {}

local function cartesian_product(lists)
    local result = {}
    if lists[1] then
       for _, elem in ipairs(lists[1]) do
          result[#result+1] = { elem }
       end
       table.remove(lists, 1)
    end

    for _, list in ipairs(lists) do
       local tmp = {}
       for _, res in ipairs(result) do
          for _, elem in ipairs(list) do
             local tmp_res = table.shallow_copy(res)
             tmp_res[#tmp_res+1] = elem
             tmp[#tmp+1] = tmp_res
          end
       end
       result = tmp
    end

    return result
end

local function do_check(check, gens, ...)
   local ok, res, mes = pcall(check, ...)
   if not ok then
      return {
         error = res,
         gens = gens,
         args = {...}
      }
   end

   return {
      result = res,
      message = mes,
      gens = gens,
      args = {...}
   }
end

local function prop(check, generators)
   local iters = fun.iter(generators):map(
      function(g)
         return fun.range(math.huge):map(function(i) return g:pick(i) end)
      end):to_list()

   local wrapped_check = function(...)
      return do_check(check, generators, ...)
   end

   return fun.zip(table.unpack(iters)):map(wrapped_check)
end

local function passed(result)
   return result.error == nil and result.result
end

local function get_children(result)
   local lists = {}
   for i, arg in ipairs(result.args) do
      local gen = result.gens[i]
      lists[#lists+1] = gen:shrink(arg)
   end
   return cartesian_product(lists)
end

local function smallest_shrink(result, depth)
   return {
      smallest = result.args,
      result = result.result,
      message = result.message,
      error = result.error,
      depth = depth
   }
end

local function shrink(result, check, child_count, depth)
   local children = get_children(result)
   if #children == 0 or #children > child_count then
      return true, smallest_shrink(result, depth)
   end
   for _, new_args in ipairs(children) do
      local res = do_check(check, result.gens, table.unpack(new_args))
      if passed(res) then
         -- pass
      else
         local found_minimum, shrunk = shrink(res, check, #children, depth + 1)
         if found_minimum then
            return true, shrunk
         else
            -- All children passed, use this as the best for now.
            -- TODO: backtrack to avoid being caught in a local minima.
            return true, smallest_shrink(res, depth)
         end
      end
   end

   return false, result
end

local DEFAULT_TIMES = 100

function QuickCheck.quick_check(check, gens, opts)
   opts = opts or {}

   local seed = opts.seed or math.floor(socket.gettime())

   Rand.set_seed(seed)
   math.randomseed(seed)

   local times = opts.times or DEFAULT_TIMES

   local iter = prop(check, gens)

   local sw = Stopwatch:new()

   for _, i, result in iter:enumerate():take(times) do
      if passed(result) then
         -- pass
      else
         local shrink_sw = Stopwatch:new()

         local ok, shrunk = shrink(result, check, math.huge, 1)
         if not ok then
            shrunk = smallest_shrink(result, 1)
         end

         local elapsed = shrink_sw:measure()
         shrunk.time_shrinking_ms = elapsed

         return false, {
            shrunk = shrunk,
            seed = seed,
            num_tests = times,
            failed_after = i,
            time_elapsed = sw:measure()
         }
      end
   end

   Rand.set_seed()

   return true, {
      seed = seed,
      num_tests = times,
      time_elapsed = sw:measure()
   }
end

function QuickCheck.assert(check, gens, opts)
   local ok, r = QuickCheck.quick_check(check, gens, opts)

   if not ok then
      local t
      if r.shrunk.error then
         t = ("Error: %s"):format(r.shrunk.error)
      elseif r.shrunk.message then
         t = ("Result: %s, %s"):format(r.shrunk.result, r.shrunk.message)
      else
         t = ("Result: %s"):format(r.shrunk.result)
      end
      local err = ([[
Property failed (after %d/%d runs, %d shrink(s)):

%s

%s
]]):format(r.failed_after, r.num_tests, r.shrunk.depth, inspect(r.shrunk.smallest, {depth = 2, override_mt = true}), t)
      local t = { err, _ = r.shrunk.smallest, __result = r }
      for i, v in ipairs(r.shrunk.smallest) do
         t["_" .. i] = v
      end
      error(t)
   end

   return true, nil
end

return QuickCheck
