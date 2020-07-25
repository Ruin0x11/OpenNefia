local Stopwatch = require("api.Stopwatch")
local config = require("internal.config")

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

local Charagen = require("mod.tools.api.Charagen")

local IGenerator = class.interface("IGenerator", {
                                      gen = "function",
                                      shrink = "function"
})

local TableGen = class.class("TableGen", IGenerator)

function TableGen:init(cb)
   self.bases = {}
   self.cb = cb
end

local function random_string(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function TableGen:gen(size)
   local base = self.cb(size)
   local new = table.deepcopy(base)
   self.bases[new] = base
   local props = table.keys(base)
   for _ = 1, size do
      local done
      repeat
         done = true
         local prop = Rand.choice(props)
         local v = new[prop]
         local ty = type(v)
         if ty == "string" then
            new[prop] = random_string(size)
         elseif ty == "number" then
            if math.floor(v) == v then
               new[prop] = Rand.rnd(1, 1000000)
            else
               new[prop] = rand.rnd_float()
            end
         elseif ty == "boolean" then
            new[prop] = Rand.one_in(2)
         else
            done = false
         end
      until done
   end
   return new
end

function TableGen:shrink(tbl)
   local t = {}
   local base = self.bases[tbl]

   for k, v in pairs(tbl) do
      local fb = base[k]
      if fb and v ~= fb then
         local new = table.shallow_copy(tbl)
         local mt = getmetatable(tbl)
         setmetatable(new, mt)
         self.bases[new] = base
         rawset(new, k, fb)
         t[#t+1] = new
      end
   end

   return t
end

local function do_check(check, gens, ...)
   local ok, res = pcall(check, ...)
   if not ok then
      return {
         error = res,
         gens = gens,
         args = {...}
      }
   end

   return {
      result = res,
      gens = gens,
      args = {...}
   }
end

local function prop(check, generators)
   local iters = fun.iter(generators):map(
      function(g)
         return fun.range(math.huge):map(function(i) return g:gen(i) end)
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
      error = result.error,
      depth = depth
   }
end

local function shrink(result, check, child_count, depth)
   local children = get_children(result)
   if #children == 0 or #children >= child_count then
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

local function quick_check(check, gens, times, opts)
   opts = opts or {}

   local seed = opts.seed or math.floor(socket.gettime())

   config["base.default_seed"] = seed
   Rand.set_seed(seed)
   math.randomseed(seed)

   assert(type(times) == "number", "Must pass in 'times', a number")

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

   config["base.default_seed"] = nil
   Rand.set_seed()

   return true, {
      seed = seed,
      num_tests = times,
      time_elapsed = sw:measure()
   }
end

local function test(ok, r)
   if not ok then
      print("Property failed: " .. inspect(r, {depth = 4, override_mt = true}), 0)
   end

   return true
end

local function prop_same_name(a, b)
   return a.name == b.name
end

local function prop_same_quality(a, b)
   return a.quality == b.quality
end

local cb = function(size)
   return Charagen.create(nil, nil, { ownerless = true, quality = 1 })
end

-- test(quick_check(prop_same_quality, {TableGen:new(cb), TableGen:new(cb)}, 10))
-- test(quick_check(prop_same_name, {TableGen:new(cb), TableGen:new(cb)}, 10))

local cb = function(size)
   return Itemgen.create(nil, nil, { ownerless = true, amount = 2 })
end

local function prop_can_stack_with(item)
   local new = item:separate()
   return new:can_stack_with(item)
end

test(quick_check(prop_can_stack_with, {TableGen:new(cb)}, 10))

-- local g = TableGen:new()
-- local a = g:shrink(g:gen())
-- local b = g:shrink(g:gen())
-- local prod = cartesian_product({a, b})
--
-- print(inspect(prod, {depth=3,override_mt=true}))

-- print(inspect(prod, {depth=3,override_mt=true}))
