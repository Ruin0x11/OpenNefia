---
--- Lua Fun - a high-performance functional programming library for LuaJIT
---
--- Copyright (c) 2013-2017 Roman Tsisyk <roman@tsisyk.com>
---
--- Distributed under the MIT/X11 License. See COPYING.md for more details.
---
-- @module fun

local exports = {}
local methods = {}

-- compatibility with Lua 5.1/5.2
local unpack = rawget(table, "unpack") or unpack

--------------------------------------------------------------------------------
-- Tools
--------------------------------------------------------------------------------

local return_if_not_empty = function(state_x, ...)
    if state_x == nil then
        return nil
    end
    return ...
end

local call_if_not_empty = function(fun, state_x, ...)
    if state_x == nil then
        return nil
    end
    return state_x, fun(...)
end

local function deepcopy(orig) -- used by cycle()
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

local iterator_mt = {
    -- usually called by for-in loop
    __call = function(self, param, state)
        return self.gen(param, state)
    end;
    __tostring = function(self)
        return '<generator>'
    end;
    -- add all exported methods
    __index = methods;
}

--- Returns a luafun-compatible iterator from an iterator triplet of
--- gen, param and state.
---
--- @function fun.wrap(gen, param, state)
--- @tparam any gen
--- @tparam any param
--- @tparam any state
local wrap = function(gen, param, state)
    return setmetatable({
        gen = gen,
        param = param,
        state = state
    }, iterator_mt), param, state
end
exports.wrap = wrap

local unwrap = function(self)
    return self.gen, self.param, self.state
end
methods.unwrap = unwrap

--------------------------------------------------------------------------------
-- Basic Functions
--------------------------------------------------------------------------------

local nil_gen = function(_param, _state)
    return nil
end

local string_gen = function(param, state)
    local state = state + 1
    if state > #param then
        return nil
    end
    local r = string.sub(param, state, state)
    return state, r
end

local ipairs_gen = ipairs({}) -- get the generating function from ipairs

local pairs_gen = pairs({ a = 0 }) -- get the generating function from pairs
local kv_iter_gen = function(tab, key)
    local value
    key, value = pairs_gen(tab, key)
    return key, key, value
end

local rawiter = function(obj, param, state)
    assert(obj ~= nil, "invalid iterator")
    if type(obj) == "table" then
        local mt = getmetatable(obj);
        if mt ~= nil then
            if mt == iterator_mt then
                return obj.gen, obj.param, obj.state
            elseif mt.__ipairs ~= nil then
                return mt.__ipairs(obj)
            elseif mt.__pairs ~= nil then
                return mt.__pairs(obj)
            end
        end
        if #obj > 0 then
            -- array
            return ipairs(obj)
        else
            -- hash
            return kv_iter_gen, obj, nil
        end
    elseif (type(obj) == "function") then
        return obj, param, state
    elseif (type(obj) == "string") then
        if #obj == 0 then
            return nil_gen, nil, nil
        end
        return string_gen, obj, 0
    end
    error(string.format('object %s of type "%s" is not iterable',
          obj, type(obj)))
end

--- Make gen, param, state iterator from the iterable object. The
--- function is a generalized version of pairs() and ipairs().
---
--- The function distinguish between arrays and maps using #arg == 0
--- check to detect maps. For arrays ipairs is used. For maps a
--- modified version of pairs is used that also returns keys. Userdata
--- objects are handled in the same way as tables.
---
--- @function fun.iter(obj)
--- @tparam list|map|string obj
--- @treturn iterator
local iter = function(obj, param, state)
    return wrap(rawiter(obj, param, state))
end
exports.iter = iter

local method0 = function(fun)
    return function(self)
        return fun(self.gen, self.param, self.state)
    end
end

local method1 = function(fun)
    return function(self, arg1)
        return fun(arg1, self.gen, self.param, self.state)
    end
end

local method2 = function(fun)
    return function(self, arg1, arg2)
        return fun(arg1, arg2, self.gen, self.param, self.state)
    end
end

local export0 = function(fun)
    return function(gen, param, state)
        return fun(rawiter(gen, param, state))
    end
end

local export1 = function(fun)
    return function(arg1, gen, param, state)
        return fun(arg1, rawiter(gen, param, state))
    end
end

local export2 = function(fun)
    return function(arg1, arg2, gen, param, state)
        return fun(arg1, arg2, rawiter(gen, param, state))
    end
end

--- Execute the fun for each iteration value. The function is equivalent to the code below:
--
---   for _it, ... in iter(gen, param, state) do
---       fun(...)
---   end
---
--- Examples:
---
---   > each(print, { a = 1, b = 2, c = 3})
---   b 2
---   a 1
---   c 3
---
---   > each(print, {1, 2, 3})
---   1
---   2
---   3
---
--- The function is used for its side effects. Implementation directly
--- applies fun to all iteration values without returning a new
--- iterator, in contrast to functions like map().
---
--- @function fun.each(fun, iter)
--- @tparam function fun
--- @tparam iterator iter
local each = function(fun, gen, param, state)
    repeat
        state = call_if_not_empty(fun, gen(param, state))
    until state == nil
end
methods.each = method1(each)
exports.each = export1(each)
-- methods.for_each = methods.each
-- exports.for_each = exports.each
-- methods.foreach = methods.each
-- exports.foreach = exports.each

--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------

local range_gen = function(param, state)
    local stop, step = param[1], param[2]
    local state = state + step
    if state > stop then
        return nil
    end
    return state, state
end

local range_rev_gen = function(param, state)
    local stop, step = param[1], param[2]
    local state = state + step
    if state < stop then
        return nil
    end
    return state, state
end

--- The iterator to create arithmetic progressions. Iteration values
--- are generated within closed interval [start, stop] (i.e. stop is
--- included). If the start argument is omitted, it defaults to 1
--- (stop > 0) or to -1 (stop < 0). If the step argument is omitted,
--- it defaults to 1 (start <= stop) or to -1 (start > stop). If step
--- is positive, the last element is the largest start + i * step less
--- than or equal to stop; if step is negative, the last element is
--- the smallest start + i * step greater than or equal to stop. step
--- must not be zero (or else an error is raised). range(0) returns
--- empty iterator.
---
--- Examples:
---
---   > for _it, v in range(5) do print(v) end
---   1
---   2
---   3
---   4
---   5
---   > for _it, v in range(-5) do print(v) end
---   -1
---   -2
---   -3
---   -4
---   -5
---   > for _it, v in range(1, 6) do print(v) end
---   1
---   2
---   3
---   4
---   5
---   6
---   > for _it, v in range(0, 20, 5) do print(v) end
---   0
---   5
---   10
---   15
---   20
---   > for _it, v in range(0, 10, 3) do print(v) end
---   0
---   3
---   6
---   9
---   > for _it, v in range(0, 1.5, 0.2) do print(v) end
---   0
---   0.2
---   0.4
---   0.6
---   0.8
---   1
---   1.2
---   1.4
---   > for _it, v in range(0) do print(v) end
---   > for _it, v in range(1) do print(v) end
---   1
---   > for _it, v in range(1, 0) do print(v) end
---   1
---   0
---   > for _it, v in range(0, 10, 0) do print(v) end
---   error: step must not be zero
---
--- @function fun.range(start[, stop[, step]])
--- @tparam number start an endpoint of the interval
--- @tparam[opt] number stop an endpoint of the interval
--- @tparam[opt] number step a step
--- @treturn iterator an iterator
local range = function(start, stop, step)
    if step == nil then
        if stop == nil then
            if start == 0 then
                return nil_gen, nil, nil
            end
            stop = start
            start = stop > 0 and 1 or -1
        end
        step = start <= stop and 1 or -1
    end

    assert(type(start) == "number", "start must be a number")
    assert(type(stop) == "number", "stop must be a number")
    assert(type(step) == "number", "step must be a number")
    assert(step ~= 0, "step must not be zero")

    if (step > 0) then
        return wrap(range_gen, {stop, step}, start - step)
    elseif (step < 0) then
        return wrap(range_rev_gen, {stop, step}, start - step)
    end
end
exports.range = range

local duplicate_table_gen = function(param_x, state_x)
    return state_x + 1, unpack(param_x)
end

local duplicate_fun_gen = function(param_x, state_x)
    return state_x + 1, param_x(state_x)
end

local duplicate_gen = function(param_x, state_x)
    return state_x + 1, param_x
end

--- The iterator returns values over and over again indefinitely. All
--- values that passed to the iterator are returned as-is during the
--- iteration.
---
--- Examples:
---
---   > each(print, take(3, duplicate('a', 'b', 'c')))
---   a       b       c
---   a       b       c
---   > each(print, take(3, duplicate('x')))
---   x
---   x
---   x
---   > for _it, a, b, c, d, e in take(3, duplicate(1, 2, 'a', 3, 'b')) do
---       print(a, b, c, d, e)
---   >> end
---   1       2       a       3       b
---   1       2       a       3       b
---   1       2       a       3       b
---
--- @function fun.duplicate(...)
--- @tparam ... objects to duplicate
--- @treturn iterator an iterator
local duplicate = function(...)
    if select('#', ...) <= 1 then
        return wrap(duplicate_gen, select(1, ...), 0)
    else
        return wrap(duplicate_table_gen, {...}, 0)
    end
end
exports.duplicate = duplicate
-- exports.replicate = duplicate
-- exports.xrepeat = duplicate

--- The iterator that returns fun(0), fun(1), fun(2), ... values indefinitely.
---
--- Examples:
---
---   > each(print, take(5, tabulate(function(x)  return 'a', 'b', 2*x end)))
---   a       b       0
---   a       b       2
---   a       b       4
---   a       b       6
---   a       b       8
---   > each(print, take(5, tabulate(function(x) return x^2 end)))
---   0
---   1
---   4
---   9
---   16
---
--- @function fun.tabulate(fun)
--- @tparam function(uint=>...) fun an unary generating function
--- @treturn iterator an iterator
local tabulate = function(fun)
    assert(type(fun) == "function")
    return wrap(duplicate_fun_gen, fun, 0)
end
exports.tabulate = tabulate

--- The iterator returns 0 indefinitely.
---
--- Examples:
---
---   > each(print, take(5, zeros()))
---   0
---   0
---   0
---   0
---   0
---
--- @function fun.zeros()
--- @treturn iterator an iterator
local zeros = function()
    return wrap(duplicate_gen, 0, 0)
end
exports.zeros = zeros

--- The iterator that returns 1 indefinitely.
---
--- Example:
---
---   > each(print, take(5, ones()))
---   1
---   1
---   1
---   1
---   1
---
--- @function fun.ones()
--- @treturn iterator an iterator
local ones = function()
    return wrap(duplicate_gen, 1, 0)
end
exports.ones = ones

local rands_gen = function(param_x, _state_x)
    return 0, math.random(param_x[1], param_x[2])
end

local rands_nil_gen = function(_param_x, _state_x)
    return 0, math.random()
end

--- The iterator returns random values using math.random(). If the n
--- and m are set then the iterator returns pseudo-random integers in
--- the [n, m) interval (i.e. m is not included). If the m is not set
--- then the iterator generates pseudo-random integers in the [0, n)
--- interval. When called without arguments returns pseudo-random real
--- numbers with uniform distribution in the interval [0, 1).
---
--- Warning
---
--- This iterator is not pure-functional and may not work as expected with some library functions.
---
--- Examples:
---
---   > each(print, take(10, rands(10, 20)))
---   19
---   17
---   11
---   19
---   12
---   13
---   14
---   16
---   10
---   11
---
---   > each(print, take(5, rands(10)))
---   7
---   6
---   5
---   9
---   0
---
---   > each(print, take(5, rands()))
---   0.79420629243124
---   0.69885246563716
---   0.5901037417281
---   0.7532286166836
---   0.080971251199854
---
--- @function fun.rands(n[, m])
--- @tparam uint n an endpoint of the interval
--- @tparam[opt] uint m an endpoint of the interval
--- @treturn iterator an iterator
local rands = function(n, m)
    if n == nil and m == nil then
        return wrap(rands_nil_gen, 0, 0)
    end
    assert(type(n) == "number", "invalid first arg to rands")
    if m == nil then
        m = n
        n = 0
    else
        assert(type(m) == "number", "invalid second arg to rands")
    end
    assert(n < m, "empty interval")
    return wrap(rands_gen, {n, m - 1}, 0)
end
exports.rands = rands

--------------------------------------------------------------------------------
-- Slicing
--------------------------------------------------------------------------------

--- This function returns the n-th element of gen, param, state
--- iterator. If the iterator does not have n items then nil is
--- returned.
---
--- Examples:
---
---   > print(nth(2, range(5)))
---   2
---
---   > print(nth(10, range(5)))
---   nil
---
---   > print(nth(2, {"a", "b", "c", "d", "e"}))
---   b
---
---   > print(nth(2, enumerate({"a", "b", "c", "d", "e"})))
---   2 b
---
--- This function is optimized for basic array and string iterators
--- and has O(1) complexity for these cases.
---
--- @function fun.nth(n, iter)
--- @tparam n uint a sequential number (indexed starting from 1, like Lua tables)
--- @tparam iterator iter
--- @treturn any n-th element of gen, param, state iterator
local nth = function(n, gen_x, param_x, state_x)
    assert(n > 0, "invalid first argument to nth")
    -- An optimization for arrays and strings
    if gen_x == ipairs_gen then
        return param_x[n]
    elseif gen_x == string_gen then
        if n <= #param_x then
            return string.sub(param_x, n, n)
        else
            return nil
        end
    end
    for i=1,n-1,1 do
        state_x = gen_x(param_x, state_x)
        if state_x == nil then
            return nil
        end
    end
    return return_if_not_empty(gen_x(param_x, state_x))
end
methods.nth = method1(nth)
exports.nth = export1(nth)

local head_call = function(state, ...)
    if state == nil then
        error("head: iterator is empty")
    end
    return ...
end

--- Extract the first element of gen, param, state iterator. If the
--- iterator is empty then an error is raised.
---
--- Examples:
---
---   > print(head({"a", "b", "c", "d", "e"}))
---   a
---   > print(head({}))
---   error: head: iterator is empty
---   > print(head(range(0)))
---   error: head: iterator is empty
---   > print(head(enumerate({"a", "b"})))
---   1 a
---
--- @function fun.head(iter)
--- @tparam iterator iter
--- @treturn any a first element of `gen, param, state` iterator
local head = function(gen, param, state)
    return head_call(gen(param, state))
end
methods.head = method0(head)
exports.head = export0(head)
-- exports.car = exports.head
-- methods.car = methods.head

--- Return a copy of gen, param, state iterator without its first
--- element. If the iterator is empty then an empty iterator is
--- returned.
---
--- Examples:
---
---   > each(print, tail({"a", "b", "c", "d", "e"}))
---   b
---   c
---   d
---   e
---   > each(print, tail({}))
---   > each(print, tail(range(0)))
---   > each(print, tail(enumerate({"a", "b", "c"})))
---   2 b
---   3 c
---
--- @function fun.tail(iter)
--- @tparam iterator iter
--- @treturn iterator `gen, param, state` iterator without a first element
local tail = function(gen, param, state)
    state = gen(param, state)
    if state == nil then
        return wrap(nil_gen, nil, nil)
    end
    return wrap(gen, param, state)
end
methods.tail = method0(tail)
exports.tail = export0(tail)
-- exports.cdr = exports.tail
-- methods.cdr = methods.tail

local take_n_gen_x = function(i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i, state_x}, ...
end

local take_n_gen = function(param, state)
    local n, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    if i >= n then
        return nil
    end
    return take_n_gen_x(i + 1, gen_x(param_x, state_x))
end

--- Examples:
---
---   > each(print, take_n(5, range(10)))
---   1
---   2
---   3
---   4
---   5
---
---   > each(print, take_n(5, enumerate(duplicate('x'))))
---   1 x
---   2 x
---   3 x
---   4 x
---   5 x
---
--- @function fun.take_n(n, iter)
--- @tparam uint n a number of elements to take
--- @tparam iterator iter
--- @treturn iterator an iterator on the subsequence of first n elements
local take_n = function(n, gen, param, state)
    assert(n >= 0, "invalid first argument to take_n")
    return wrap(take_n_gen, {n, gen, param}, {0, state})
end
methods.take_n = method1(take_n)
exports.take_n = export1(take_n)

local take_while_gen_x = function(fun, state_x, ...)
    if state_x == nil or not fun(...) then
        return nil
    end
    return state_x, ...
end

local take_while_gen = function(param, state_x)
    local fun, gen_x, param_x = param[1], param[2], param[3]
    return take_while_gen_x(fun, gen_x(param_x, state_x))
end

--- Examples:
---
---   > each(print, take_while(function(x) return x < 5 end, range(10)))
---   1
---   2
---   3
---   4
---
---   > each(print, take_while(function(i, a) return i ~=a end,
---       enumerate({5, 3, 4, 4, 2})))
---   1       5
---   2       3
---   3       4
---
--- @function fun.take_while(fun, iter)
--- @tparam function(any=>bool) fun
--- @tparam iterator iter
--- @treturn iterator an iterator on the longest prefix of `gen, param, state` elements that satisfy `predicate`.
--- @see fun.filter
local take_while = function(fun, gen, param, state)
    assert(type(fun) == "function", "invalid first argument to take_while")
    return wrap(take_while_gen, {fun, gen, param}, state)
end
methods.take_while = method1(take_while)
exports.take_while = export1(take_while)

--- An alias for take_n() and take_while() that autodetects required
--- function based on n_or_predicate type.
---
--- @function fun.take(n_or_fun, iter)
--- @tparam uint|function(any=>bool) n_or_fun
--- @tparam iterator iter
--- @treturn iterator
local take = function(n_or_fun, gen, param, state)
    if type(n_or_fun) == "number" then
        return take_n(n_or_fun, gen, param, state)
    else
        return take_while(n_or_fun, gen, param, state)
    end
end
methods.take = method1(take)
exports.take = export1(take)

--- Examples:
---
---   > each(print, drop_n(2, range(5)))
---   3
---   4
---   5
---
---   > each(print, drop_n(2, enumerate({'a', 'b', 'c', 'd', 'e'})))
---   3       c
---   4       d
---   5       e
---
--- @function fun.drop_n(n, iter)
--- @tparam uint n the number of elements to drop
--- @tparam iterator iter
--- @treturn iterator `gen, param, state` iterator after skipping first n elements
local drop_n = function(n, gen, param, state)
    assert(n >= 0, "invalid first argument to drop_n")
    local i
    for i=1,n,1 do
        state = gen(param, state)
        if state == nil then
            return wrap(nil_gen, nil, nil)
        end
    end
    return wrap(gen, param, state)
end
methods.drop_n = method1(drop_n)
exports.drop_n = export1(drop_n)

local drop_while_x = function(fun, state_x, ...)
    if state_x == nil or not fun(...) then
        return state_x, false
    end
    return state_x, true, ...
end

--- Examples:
---
---   > each(print, drop_while(function(x) return x < 5 end, range(10)))
---   5
---   6
---   7
---   8
---   9
---   10
---
--- @function fun.drop_while(fun, iter)
--- @tparam function(any=>bool) fun
--- @tparam iterator iter
--- @treturn iterator `gen, param, state` after skipping the longest prefix of elements that satisfy `predicate`.
local drop_while = function(fun, gen_x, param_x, state_x)
    assert(type(fun) == "function", "invalid first argument to drop_while")
    local cont, state_x_prev
    repeat
        state_x_prev = deepcopy(state_x)
        state_x, cont = drop_while_x(fun, gen_x(param_x, state_x))
    until not cont
    if state_x == nil then
        return wrap(nil_gen, nil, nil)
    end
    return wrap(gen_x, param_x, state_x_prev)
end
methods.drop_while = method1(drop_while)
exports.drop_while = export1(drop_while)

--- An alias for drop_n() and drop_while() that autodetects required
--- function based on n_or_predicate type.
---
--- @function fun.drop(n_or_fun, iter)
--- @tparam uint|function(any=>bool) n_or_fun
--- @tparam iterator iter
--- @treturn iterator
local drop = function(n_or_fun, gen_x, param_x, state_x)
    if type(n_or_fun) == "number" then
        return drop_n(n_or_fun, gen_x, param_x, state_x)
    else
        return drop_while(n_or_fun, gen_x, param_x, state_x)
    end
end
methods.drop = method1(drop)
exports.drop = export1(drop)

--- Return an iterator pair where the first operates on the longest
--- prefix (possibly empty) of gen, param, state iterator of elements
--- that satisfy predicate and second operates the remainder of gen,
--- param, state iterator. Equivalent to:
---
---   return take(n_or_predicate, gen, param, state),
---          drop(n_or_predicate, gen, param, state);
---
--- Examples:
---
---   > each(print, zip(span(function(x) return x < 5 end, range(10))))
---   1       5
---   2       6
---   3       7
---   4       8
---
---   > each(print, zip(span(5, range(10))))
---   1       6
---   2       7
---   3       8
---   4       9
---   5       10
---
--- @function fun.split(n_or_fun, iter)
--- @tparam uint|function(any=>bool) n_or_fun
--- @tparam iterator iter
--- @treturn[1][1] iterator
--- @treturn[1][2] iterator
local split = function(n_or_fun, gen_x, param_x, state_x)
    return take(n_or_fun, gen_x, param_x, state_x),
           drop(n_or_fun, gen_x, param_x, state_x)
end
methods.split = method1(split)
exports.split = export1(split)
-- methods.split_at = methods.split
-- exports.split_at = exports.split
-- methods.span = methods.split
-- exports.span = exports.split

--------------------------------------------------------------------------------
-- Indexing
--------------------------------------------------------------------------------

--- The function returns the position of the first element in the
--- given iterator which is equal (using ==) to the query element, or
--- nil if there is no such element.
---
--- Examples:
---
---   > print(index(2, range(0)))
---   nil
---
---   > print(index("b", {"a", "b", "c", "d", "e"}))
---   2
---
--- @function fun.index(x, iter)
--- @tparam any x a value to find
--- @tparam iterator iter
--- @treturn[opt] uint the position of the first element that equals to the x
local index = function(x, gen, param, state)
    local i = 1
    for _k, r in gen, param, state do
        if r == x then
            return i
        end
        i = i + 1
    end
    return nil
end
methods.index = method1(index)
exports.index = export1(index)
-- methods.index_of = methods.index
-- exports.index_of = exports.index
-- methods.elem_index = methods.index
-- exports.elem_index = exports.index

local indexes_gen = function(param, state)
    local x, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    local r
    while true do
        state_x, r = gen_x(param_x, state_x)
        if state_x == nil then
            return nil
        end
        i = i + 1
        if r == x then
            return {i, state_x}, i
        end
    end
end

--- The function returns an iterator to positions of elements which
--- equals to the query element.
---
--- Examples:
---   > each(print, indexes("a", {"a", "b", "c", "d", "e", "a", "b", "a", "a"}))
---   1
---   6
---   9
---   10
---
--- @function fun.indexes(x, iter)
--- @tparam any x a value to find
--- @tparam iterator iter
--- @treturn iterator(uint) an iterator which positions of elements that equal to the x
--- @see fun.filter
local indexes = function(x, gen, param, state)
    return wrap(indexes_gen, {x, gen, param}, {0, state})
end
methods.indexes = method1(indexes)
exports.indexes = export1(indexes)
-- methods.elem_indexes = methods.indexes
-- exports.elem_indexes = exports.indexes
-- methods.indices = methods.indexes
-- exports.indices = exports.indexes
-- methods.elem_indices = methods.indexes
-- exports.elem_indices = exports.indexes

--------------------------------------------------------------------------------
-- Filtering
--------------------------------------------------------------------------------

local filter1_gen = function(fun, gen_x, param_x, state_x, a)
    while true do
        if state_x == nil or fun(a) then break; end
        state_x, a = gen_x(param_x, state_x)
    end
    return state_x, a
end

-- call each other
local filterm_gen
local filterm_gen_shrink = function(fun, gen_x, param_x, state_x)
    return filterm_gen(fun, gen_x, param_x, gen_x(param_x, state_x))
end

filterm_gen = function(fun, gen_x, param_x, state_x, ...)
    if state_x == nil then
        return nil
    end
    if fun(...) then
        return state_x, ...
    end
    return filterm_gen_shrink(fun, gen_x, param_x, state_x)
end

local filter_detect = function(fun, gen_x, param_x, state_x, ...)
    if select('#', ...) < 2 then
        return filter1_gen(fun, gen_x, param_x, state_x, ...)
    else
        return filterm_gen(fun, gen_x, param_x, state_x, ...)
    end
end

local filter_gen = function(param, state_x)
    local fun, gen_x, param_x = param[1], param[2], param[3]
    return filter_detect(fun, gen_x, param_x, gen_x(param_x, state_x))
end

--- Return a new iterator of those elements that satisfy the predicate.
---
--- Examples:
---
---   > each(print, filter(function(x) return x % 3 == 0 end, range(10)))
---   3
---   6
---   9
---
---   > each(print, take(5, filter(function(i, x) return i % 3 == 0 end,
---       enumerate(duplicate('x')))))
---   3       x
---   6       x
---   9       x
---   12      x
---   15      x
---
--- @function fun.filter(fun, iter)
--- @tparam function(...=>bool) an predicate to filter the iterator
--- @tparam iterator(...) iter
--- @treturn iterator(...)
--- @see fun.take_while
--- @see fun.drop_while
local filter = function(fun, gen, param, state)
    return wrap(filter_gen, {fun, gen, param}, state)
end
methods.filter = method1(filter)
exports.filter = export1(filter)
-- methods.remove_if = methods.filter
-- exports.remove_if = exports.filter

--- If `regexp_or_predicate` is string then the parameter is used as a
--- regular expression to build filtering predicate. Otherwise the
--- function is just an alias for filter().
---
--- Equivalent to:
---
---   local fun = regexp_or_predicate
---   if type(regexp_or_predicate) == "string" then
---       fun = function(x) return string.find(x, regexp_or_predicate) ~= nil end
---   end
---   return filter(fun, gen, param, state)
---
--- Examples:
---
---   lines_to_grep = {
---       [[Emily]],
---       [[Chloe]],
---       [[Megan]],
---       [[Jessica]],
---       [[Emma]],
---       [[Sarah]],
---       [[Elizabeth]],
---       [[Sophie]],
---       [[Olivia]],
---       [[Lauren]]
---   }
---
---   each(print, grep("^Em", lines_to_grep))
---   --[[test
---   Emily
---   Emma
---   --test]]
---
---   each(print, grep("^P", lines_to_grep))
---   --[[test
---   --test]]
---
---   > each(print, grep(function(x) return x % 3 == 0 end, range(10)))
---   3
---   6
---   9
---
--- @function fun.grep(fun_or_regexp, iter)
--- @tparam function(...=>bool)|string fun_or_regexp
--- @tparam iterator iter
--- @treturn iterator(...)
local grep = function(fun_or_regexp, gen, param, state)
    local fun = fun_or_regexp
    if type(fun_or_regexp) == "string" then
        fun = function(x) return string.find(x, fun_or_regexp) ~= nil end
    end
    return filter(fun, gen, param, state)
end
methods.grep = method1(grep)
exports.grep = export1(grep)

--- The function returns two iterators where elements do and do not
--- satisfy the prediucate. Equivalent to:
---
---   return filter(predicate, gen', param', state'),
---   filter(function(...) return not predicate(...) end, gen, param, state);
---
--- The function make a clone of the source iterator. Iterators
--- especially returned in tables to work with zip() and other
--- functions.
---
--- Examples:
---
---   > each(print, zip(partition(function(i, x) return i % 3 == 0 end, range(10))))
---   3       1
---   6       2
---   9       4
---
--- @function fun.partition(fun, iter)
--- @tparam any x a value to find
--- @tparam iterator iter
--- @treturn[1][1] iterator
--- @treturn[1][2] iterator
--- @see fun.split
local partition = function(fun, gen, param, state)
    local neg_fun = function(...)
        return not fun(...)
    end
    return filter(fun, gen, param, state),
           filter(neg_fun, gen, param, state)
end
methods.partition = method1(partition)
exports.partition = export1(partition)

--------------------------------------------------------------------------------
-- Reducing
--------------------------------------------------------------------------------

local foldl_call = function(fun, start, state, ...)
    if state == nil then
        return nil, start
    end
    return state, fun(start, ...)
end

--- The function reduces the iterator from left to right using the
--- binary operator accfun and the initial value initval. Equivalent
--- to:
---
---   local val = initval
---   for _k, ... in gen, param, state do
---       val = accfun(val, ...)
---   end
---   return val
---
--- Examples:
---
---   > print(foldl(function(acc, x) return acc + x end, 0, range(5)))
---   15
---
---   > print(foldl(operator.add, 0, range(5)))
---   15
---
---   > print(foldl(function(acc, x, y) return acc + x * y; end, 0,
---       zip(range(1, 5), {4, 3, 2, 1})))
---   20
---
--- @function fun.foldl(fun, start, iter)
--- @tparam function(X,Y=>X) accfun – an accumulating function
--- @tparam[opt] X initval an initial value that passed to accfun on the first iteration
--- @tparam iterator iter
--- @treturn X
local foldl = function(fun, start, gen_x, param_x, state_x)
    while true do
        state_x, start = foldl_call(fun, start, gen_x(param_x, state_x))
        if state_x == nil then
            break;
        end
    end
    return start
end
methods.foldl = method2(foldl)
exports.foldl = export2(foldl)
-- methods.reduce = methods.foldl
-- exports.reduce = exports.foldl

--- Return a number of elements in gen, param, state iterator. This
--- function is equivalent to #obj for basic array and string
--- iterators.
---
--- Examples:
---
---   > print(length({"a", "b", "c", "d", "e"}))
---   5
---
---   > print(length({}))
---   0
---
---   > print(length(range(0)))
---   0
---
--- Warning
---
--- An attempt to call this function on an infinite iterator will result an infinite loop.
---
--- Note
---
--- This function has O(n) complexity for all iterators except basic array and string iterators.
---
--- @function fun.length(iter)
--- @tparam iterator iter
--- @treturn uint a number of elements in gen, param, state iterator.
local length = function(gen, param, state)
    if gen == ipairs_gen or gen == string_gen then
        return #param
    end
    local len = 0
    repeat
        state = gen(param, state)
        len = len + 1
    until state == nil
    return len - 1
end
methods.length = method0(length)
exports.length = export0(length)

--- Example:
---
---   > print(is_null({"a", "b", "c", "d", "e"}))
---   false
---
---   > print(is_null({}))
---   true
---
---   > print(is_null(range(0)))
---   true
---
--- @function fun.is_null(iter)
--- @tparam iterator iter
--- @tparam true when `gen, param, state` iterator is empty or finished. false otherwise.
local is_null = function(gen, param, state)
    return gen(param, deepcopy(state)) == nil
end
methods.is_null = method0(is_null)
exports.is_null = export0(is_null)

--- The function takes two iterators and returns true if the first iterator is a prefix of the second.
---
--- Examples:
---
---   > print(is_prefix_of({"a"}, {"a", "b", "c"}))
---   true
---
---   > print(is_prefix_of(range(6), range(5)))
---   false
---
--- @function fun.is_prefix_of(iter_x, iter_y)
--- @tparam iterator iter_x
--- @tparam iterator iter_y
--- @treturn bool
local is_prefix_of = function(iter_x, iter_y)
    local gen_x, param_x, state_x = iter(iter_x)
    local gen_y, param_y, state_y = iter(iter_y)

    local r_x, r_y
    for i=1,10,1 do
        state_x, r_x = gen_x(param_x, state_x)
        state_y, r_y = gen_y(param_y, state_y)
        if state_x == nil then
            return true
        end
        if state_y == nil or r_x ~= r_y then
            return false
        end
    end
end
methods.is_prefix_of = is_prefix_of
exports.is_prefix_of = is_prefix_of

--- Returns true if all return values of iterator satisfy the
--- predicate.
---
--- Examples:
---
---   > print(all(function(x) return x end, {true, true, true, true}))
---   true
---
---   > print(all(function(x) return x end, {true, true, true, false}))
---   false
---
--- @function fun.all(fun, iter)
--- @tparam function(...=>bool) fun a predicate
--- @tparam iterator(...) iter
--- @treturn bool
local all = function(fun, gen_x, param_x, state_x)
    local r
    repeat
        state_x, r = call_if_not_empty(fun, gen_x(param_x, state_x))
    until state_x == nil or not r
    return state_x == nil
end
methods.all = method1(all)
exports.all = export1(all)
-- methods.every = methods.all
-- exports.every = exports.all

--- Returns true if at least one return values of iterator satisfy the
--- predicate. The iteration stops on the first such value. Therefore,
--- infinity iterators that have at least one satisfying value might
--- work.
---
--- Examples:
---
---   > print(any(function(x) return x end, {false, false, false, false}))
---   false
---
---   > print(any(function(x) return x end, {false, false, false, true}))
---   true
---
--- @function fun.any(fun, iter)
--- @tparam function(...=>bool) predicate a predicate
--- @tparam iterator(...) iter
--- @treturn bool
local any = function(fun, gen_x, param_x, state_x)
    local r
    repeat
        state_x, r = call_if_not_empty(fun, gen_x(param_x, state_x))
    until state_x == nil or r
    return not not r
end
methods.any = method1(any)
exports.any = export1(any)
-- methods.some = methods.any
-- exports.some = exports.any

--- Sum up all iteration values. An optimized alias for:
---
---   foldl(operator.add, 0, gen, param, state)
---
--- For an empty iterator 0 is returned.
---
--- Examples:
---
---   > print(sum(range(5)))
---   15
---
--- @function fun.sum(iter)
--- @tparam iterator(number) iter
--- @treturn number
local sum = function(gen, param, state)
    local s = 0
    local r = 0
    repeat
        s = s + r
        state, r = gen(param, state)
    until state == nil
    return s
end
methods.sum = method0(sum)
exports.sum = export0(sum)

--- Multiply all iteration values. An optimized alias for:
---
---   foldl(operator.mul, 1, gen, param, state)
---
--- For an empty iterator 1 is returned.
---
--- Examples:
---
---   > print(product(range(1, 5)))
---   120
---
--- @function fun.product(iter)
--- @tparam iterator(number) iter
--- @treturn number
local product = function(gen, param, state)
    local p = 1
    local r = 1
    repeat
        p = p * r
        state, r = gen(param, state)
    until state == nil
    return p
end
methods.product = method0(product)
exports.product = export0(product)

local min_cmp = function(m, n)
    if n < m then return n else return m end
end

local max_cmp = function(m, n)
    if n > m then return n else return m end
end

--- Return a minimum value from the iterator using operator.min() or <
--- for numbers and other types respectivly. The iterator must be
--- non-null, otherwise an error is raised.
---
--- Examples:
---
---   > print(min(range(1, 10, 1)))
---   1
---
---   > print(min({"f", "d", "c", "d", "e"}))
---   c
---
---   > print(min({}))
---   error: min: iterator is empty
---
--- @function fun.min(iter)
--- @tparam iterator iter
--- @treturn any
local min = function(gen, param, state)
    local state, m = gen(param, state)
    if state == nil then
        error("min: iterator is empty")
    end

    local cmp
    if type(m) == "number" then
        -- An optimization: use math.min for numbers
        cmp = math.min
    else
        cmp = min_cmp
    end

    for _, r in gen, param, state do
        m = cmp(m, r)
    end
    return m
end
methods.min = method0(min)
exports.min = export0(min)
-- methods.minimum = methods.min
-- exports.minimum = exports.min

--- Return a minimum value from the iterator using the `cmp` as a <
--- operator. The iterator must be non-null, otherwise an error is
--- raised.
---
--- Examples:
---
---   > function min_cmp(a, b) if -a < -b then return a else return b end end
---   > print(min_by(min_cmp, range(1, 10, 1)))
---   9
---
--- @function fun.min_by(cmp, iter)
--- @tparam function(any,any=>bool) cmp
--- @tparam iterator iter
--- @treturn any
local min_by = function(cmp, gen_x, param_x, state_x)
    local state_x, m = gen_x(param_x, state_x)
    if state_x == nil then
        error("min: iterator is empty")
    end

    for _, r in gen_x, param_x, state_x do
        m = cmp(m, r)
    end
    return m
end
methods.min_by = method1(min_by)
exports.min_by = export1(min_by)
-- methods.minimum_by = methods.min_by
-- exports.minimum_by = exports.min_by

--- Return a maximum value from the iterator using operator.max() or >
--- for numbers and other types respectivly.
---
--- The iterator must be non-null, otherwise an error is raised.
---
--- Examples:
---
---   > print(max(range(1, 10, 1)))
---   9
---
---   > print(max({"f", "d", "c", "d", "e"}))
---   f
---
---   > print(max({}))
---   error: max: iterator is empty
---
--- @function fun.max(cmp, iter)
--- @tparam iterator iter
--- @treturn any
local max = function(gen_x, param_x, state_x)
    local state_x, m = gen_x(param_x, state_x)
    if state_x == nil then
        error("max: iterator is empty")
    end

    local cmp
    if type(m) == "number" then
        -- An optimization: use math.max for numbers
        cmp = math.max
    else
        cmp = max_cmp
    end

    for _, r in gen_x, param_x, state_x do
        m = cmp(m, r)
    end
    return m
end
methods.max = method0(max)
exports.max = export0(max)
-- methods.maximum = methods.max
-- exports.maximum = exports.max

--- Return a maximum value from the iterator using the cmp as a >
--- operator. The iterator must be non-null, otherwise an error is
--- raised.
---
--- Examples:
---
---   > function max_cmp(a, b) if -a > -b then return a else return b end end
---   > print(max_by(max_cmp, range(1, 10, 1)))
---   1
---
--- @function fun.max_by(cmp, iter)
--- @tparam function(any,any=>bool) cmp
--- @tparam iterator iter
--- @treturn any
local max_by = function(cmp, gen_x, param_x, state_x)
    local state_x, m = gen_x(param_x, state_x)
    if state_x == nil then
        error("max: iterator is empty")
    end

    for _, r in gen_x, param_x, state_x do
        m = cmp(m, r)
    end
    return m
end
methods.max_by = method1(max_by)
exports.max_by = export1(max_by)
-- methods.maximum_by = methods.maximum_by
-- exports.maximum_by = exports.maximum_by

local totable = function(gen_x, param_x, state_x)
    local tab, key, val = {}
    while true do
        state_x, val = gen_x(param_x, state_x)
        if state_x == nil then
            break
        end
        table.insert(tab, val)
    end
    return tab
end
methods.totable = method0(totable)
exports.totable = export0(totable)

local tomap = function(gen_x, param_x, state_x)
    local tab, key, val = {}
    while true do
        state_x, key, val = gen_x(param_x, state_x)
        if state_x == nil then
            break
        end
        tab[key] = val
    end
    return tab
end
methods.tomap = method0(tomap)
exports.tomap = export0(tomap)

--------------------------------------------------------------------------------
-- Transformations
--------------------------------------------------------------------------------

local map_gen = function(param, state)
    local gen_x, param_x, fun = param[1], param[2], param[3]
    return call_if_not_empty(fun, gen_x(param_x, state))
end

--- Return a new iterator by applying the fun to each element of gen,
--- param, state iterator. The mapping is performed on the fly and no
--- values are buffered.
---
--- Examples:
---
---   > each(print, map(function(x) return 2 * x end, range(4)))
---   2
---   4
---   6
---   8
---
---   fun = function(...) return 'map', ... end
---   > each(print, map(fun, range(4)))
---   map 1
---   map 2
---   map 3
---   map 4
---
--- @function fun.map(fun, iter)
--- @tparam function(...=>...) fun a function to apply
--- @tparam iterator iter
--- @tparam iterator(...) a new iterator
local map = function(fun, gen, param, state)
    return wrap(map_gen, {gen, param, fun}, state)
end
methods.map = method1(map)
exports.map = export1(map)

local enumerate_gen_call = function(state, i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i + 1, state_x}, i, ...
end

local enumerate_gen = function(param, state)
    local gen_x, param_x = param[1], param[2]
    local i, state_x = state[1], state[2]
    return enumerate_gen_call(state, i, gen_x(param_x, state_x))
end

--- Return a new iterator by enumerating all elements of the gen,
--- param, state iterator starting from 1. The mapping is performed on
--- the fly and no values are buffered.
---
--- Examples:
---
---   > each(print, enumerate({"a", "b", "c", "d", "e"}))
---   1 a
---   2 b
---   3 c
---   4 d
---   5 e
---
---   > each(print, enumerate(zip({"one", "two", "three", "four", "five"},
---       {"a", "b", "c", "d", "e"})))
---   1 one a
---   2 two b
---   3 three c
---   4 four d
---   5 five e
---
--- @function fun.enumerate(iter)
--- @tparam iterator(...) iter
--- @treturn iterator(uint,...) a new iterator
local enumerate = function(gen, param, state)
    return wrap(enumerate_gen, {gen, param}, {1, state})
end
methods.enumerate = method0(enumerate)
exports.enumerate = export0(enumerate)

local intersperse_call = function(i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i + 1, state_x}, ...
end

local intersperse_gen = function(param, state)
    local x, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    if i % 2 == 1 then
        return {i + 1, state_x}, x
    else
        return intersperse_call(i, gen_x(param_x, state_x))
    end
end

-- TODO: interperse must not add x to the tail

--- Return a new iterator where the x value is interspersed between
--- the elements of the source iterator. The x value can also be added
--- as a last element of returning iterator if the source iterator
--- contains the odd number of elements.
---
---   Examples:
---
---   > each(print, intersperse("x", {"a", "b", "c", "d", "e"}))
---   a
---   x
---   b
---   x
---   c
---   x
---   d
---   x
---   e
---   x
---
--- @function fun.intersperse(x, iter)
--- @tparam any x
--- @tparam iterator iter
--- @treturn iterator a new iterator
local intersperse = function(x, gen, param, state)
    return wrap(intersperse_gen, {x, gen, param}, {0, state})
end
methods.intersperse = method1(intersperse)
exports.intersperse = export1(intersperse)

--------------------------------------------------------------------------------
-- Compositions
--------------------------------------------------------------------------------

local function zip_gen_r(param, state, state_new, ...)
    if #state_new == #param / 2 then
        return state_new, ...
    end

    local i = #state_new + 1
    local gen_x, param_x = param[2 * i - 1], param[2 * i]
    local state_x, r = gen_x(param_x, state[i])
    if state_x == nil then
        return nil
    end
    table.insert(state_new, state_x)
    return zip_gen_r(param, state, state_new, r, ...)
end

local zip_gen = function(param, state)
    return zip_gen_r(param, state, {})
end

-- A special hack for zip/chain to skip last two state, if a wrapped iterator
-- has been passed
local numargs = function(...)
    local n = select('#', ...)
    if n >= 3 then
        -- Fix last argument
        local it = select(n - 2, ...)
        if type(it) == 'table' and getmetatable(it) == iterator_mt and
           it.param == select(n - 1, ...) and it.state == select(n, ...) then
            return n - 2
        end
    end
    return n
end

--- Return a new iterator where i-th return value contains the i-th
--- element from each of the iterators. The returned iterator is
--- truncated in length to the length of the shortest iterator. For
--- multi-return iterators only the first variable is used.
---
--- Examples:
---
---   > dump(zip({"a", "b", "c", "d"}, {"one", "two", "three"}))
---   a one
---   b two
---   c three
---
---   > each(print, zip())
---
---   > each(print, zip(range(5), {'a', 'b', 'c'}, rands()))
---   1       a       0.57514179487402
---   2       b       0.79693061238668
---   3       c       0.45174307459403
---
---   > each(print, zip(partition(function(x) return x > 7 end, range(1, 15, 1))))
---   8       1
---   9       2
---   10      3
---   11      4
---   12      5
---   13      6
---   14      7
---
--- @function fun.zip(...)
--- @tparam iterator... ... iterators to "zip"
--- @treturn iterator an iterator
local zip = function(...)
    local n = numargs(...)
    if n == 0 then
        return wrap(nil_gen, nil, nil)
    end
    local param = { [2 * n] = 0 }
    local state = { [n] = 0 }

    local i, gen_x, param_x, state_x
    for i=1,n,1 do
        local it = select(n - i + 1, ...)
        gen_x, param_x, state_x = rawiter(it)
        param[2 * i - 1] = gen_x
        param[2 * i] = param_x
        state[i] = state_x
    end

    return wrap(zip_gen, param, state)
end
methods.zip = zip
exports.zip = zip

local cycle_gen_call = function(param, state_x, ...)
    if state_x == nil then
        local gen_x, param_x, state_x0 = param[1], param[2], param[3]
        return gen_x(param_x, deepcopy(state_x0))
    end
    return state_x, ...
end

local cycle_gen = function(param, state_x)
    local gen_x, param_x, state_x0 = param[1], param[2], param[3]
    return cycle_gen_call(param, gen_x(param_x, state_x))
end

--- Make a new iterator that returns elements from {gen, param, state}
--- iterator until the end and then “restart” iteration using a saved
--- clone of {gen, param, state}. The returned iterator is constant
--- space and no return values are buffered. Instead of that the
--- function make a clone of the source {gen, param, state} iterator.
--- Therefore, the source iterator must be pure functional to make an
--- indentical clone. Infinity iterators are supported, but are not
--- recommended.
---
--- Note
---
--- {gen, param, state} must be pure functional to work properly with the function.
---
--- Examples:
---
---   > each(print, take(15, cycle(range(5))))
---   1
---   2
---   3
---   4
---   5
---   1
---   2
---   3
---   4
---   5
---   1
---   2
---   3
---   4
---   5
---
---   > each(print, take(15, cycle(zip(range(5), {"a", "b", "c", "d", "e"}))))
---   1       a
---   2       b
---   3       c
---   4       d
---   5       e
---   1       a
---   2       b
---   3       c
---   4       d
---   5       e
---   1       a
---   2       b
---   3       c
---   4       d
---   5       e
---
--- @function fun.cycle(iter)
--- @tparam iterator iter
--- @treturn iterator
local cycle = function(gen, param, state)
    return wrap(cycle_gen, {gen, param, state}, deepcopy(state))
end
methods.cycle = method0(cycle)
exports.cycle = export0(cycle)

-- call each other
local chain_gen_r1
local chain_gen_r2 = function(param, state, state_x, ...)
    if state_x == nil then
        local i = state[1]
        i = i + 1
        if param[3 * i - 1] == nil then
            return nil
        end
        local state_x = param[3 * i]
        return chain_gen_r1(param, {i, state_x})
    end
    return {state[1], state_x}, ...
end

chain_gen_r1 = function(param, state)
    local i, state_x = state[1], state[2]
    local gen_x, param_x = param[3 * i - 2], param[3 * i - 1]
    return chain_gen_r2(param, state, gen_x(param_x, state[2]))
end

--- Make an iterator that returns elements from the first iterator
--- until it is exhausted, then proceeds to the next iterator, until
--- all of the iterators are exhausted. Used for treating consecutive
--- iterators as a single iterator. Infinity iterators are supported,
--- but are not recommended.
---
--- Examples:
---
---   > each(print, chain(range(2), {"a", "b", "c"}, {"one", "two", "three"}))
---   1
---   2
---   a
---   b
---   c
---   one
---   two
---   three
---
---   > each(print, take(15, cycle(chain(enumerate({"a", "b", "c"}),
---       {"one", "two", "three"}))))
---   1       a
---   2       b
---   3       c
---   one
---   two
---   three
---   1       a
---   2       b
---   3       c
---   one
---   two
---   three
---   1       a
---   2       b
---   3       c
---
--- @function fun.chain(...)
--- @tparam iterator... ... iterators to chain
--- @treturn iterator a consecutive iterator from sources (left from right)
local chain = function(...)
    local n = numargs(...)
    if n == 0 then
        return wrap(nil_gen, nil, nil)
    end

    local param = { [3 * n] = 0 }
    local i, gen_x, param_x, state_x
    for i=1,n,1 do
        local elem = select(i, ...)
        gen_x, param_x, state_x = iter(elem)
        param[3 * i - 2] = gen_x
        param[3 * i - 1] = param_x
        param[3 * i] = state_x
    end

    return wrap(chain_gen_r1, param, {1, param[3]})
end
methods.chain = chain
exports.chain = chain

--------------------------------------------------------------------------------
-- Operators
--------------------------------------------------------------------------------

-- @table operator
local operator = {
    ----------------------------------------------------------------------------
    -- Comparison operators
    ----------------------------------------------------------------------------
    lt  = function(a, b) return a < b end,
    le  = function(a, b) return a <= b end,
    eq  = function(a, b) return a == b end,
    ne  = function(a, b) return a ~= b end,
    ge  = function(a, b) return a >= b end,
    gt  = function(a, b) return a > b end,

    ----------------------------------------------------------------------------
    -- Arithmetic operators
    ----------------------------------------------------------------------------
    add = function(a, b) return a + b end,
    div = function(a, b) return a / b end,
    floordiv = function(a, b) return math.floor(a/b) end,
    intdiv = function(a, b)
        local q = a / b
        if a >= 0 then return math.floor(q) else return math.ceil(q) end
    end,
    mod = function(a, b) return a % b end,
    mul = function(a, b) return a * b end,
    neq = function(a) return -a end,
    unm = function(a) return -a end, -- an alias
    pow = function(a, b) return a ^ b end,
    sub = function(a, b) return a - b end,
    truediv = function(a, b) return a / b end,

    ----------------------------------------------------------------------------
    -- String operators
    ----------------------------------------------------------------------------
    concat = function(a, b) return a..b end,
    len = function(a) return #a end,
    length = function(a) return #a end, -- an alias

    ----------------------------------------------------------------------------
    -- Logical operators
    ----------------------------------------------------------------------------
    land = function(a, b) return a and b end,
    lor = function(a, b) return a or b end,
    lnot = function(a) return not a end,
    truth = function(a) return not not a end,
}
exports.operator = operator
methods.operator = operator
exports.op = operator
methods.op = operator

--------------------------------------------------------------------------------
-- OpenNefia modifications
--------------------------------------------------------------------------------

-- aliases for consistent naming (underscored)
-- the originals shouldn't be deleted to be able to use the existing
-- ecosystem of code that uses luafun

--- The function reduces the iterator from left to right using
--- tab[val1] = val2 expression.
---
--- Examples:
---
---   > local tab = tomap(zip(range(1, 7), 'abcdef'))
---   > print(type(tab), #tab)
---   table   6
---   > each(print, iter(tab))
---   a
---   b
---   c
---   d
---   e
---   f
---
--- @function fun.to_map(iter)
--- @tparam iterator iter
--- @treturn map a new table (map) from iterated values.
exports.to_map = exports.tomap
methods.to_map = methods.tomap

--- The function reduces the iterator from left to right using
--- table.insert.
---
--- Examples:
---
---   > local tab = to_list("abcdef")
---   > print(type(tab), #tab)
---   table 6
---   > each(print, tab)
---   a
---   b
---   c
---   d
---   e
---   f
---
--- @function fun.to_list(iter)
--- @tparam iterator iter
--- @treturn list a new table (list) from iterated values.
exports.to_list = exports.totable
methods.to_list = methods.totable

--- Finds the first index in an iterator that satisfies a predicate.
---
--- @function fun.index_by(fun, iter)
--- @tparam function(...=>bool) fun
--- @tparam iterator iter
--- @treturn[opt] ...
local index_by = function(fun, gen, param, state)
    local i = 1
    for _k, r in gen, param, state do
        if fun(r) then
            return i
        end
        i = i + 1
    end
    return nil
end
methods.index_by = method1(index_by)
exports.index_by = export1(index_by)

--- Returns an iterator of fields from an iterator of tables.
--- Equivalent to:
---
---   fun.map(function(i) return i[field] end)
---
--- @function fun.extract(field, iter)
--- @tparam string field
--- @tparam iterator iterator
--- @treturn iterator
local extract = function(field, gen, param, state)
   return map(function(i) return i[field] end, gen, param, state)
end
methods.extract = method1(extract)
exports.extract = export1(extract)

--- Returns all elements in an iterator whose table field is truthy.
--- Equivalent to:
---
---   fun.filter(function(i) return i[field] end)
---
--- @function fun.filter_by(field, iter)
--- @tparam string field
--- @tparam iterator iter
--- @treturn iterator
local filter_by = function(field, gen, param, state)
   return filter(function(i) return i[field] end, gen, param, state)
end
methods.filter_by = method1(filter_by)
exports.filter_by = export1(filter_by)

--- Transforms an iterator of varargs into an iterator of lists.
---
--- @function fun.tuples(iter)
--- @tparam iterator iter
--- @treturn iterator(list)
local tuples = function(gen, param, state)
   return map(function(...) return {...} end, gen, param, state)
end
methods.tuples = method0(tuples)
exports.tuples = export0(tuples)

--- Applies a function which returns a list to all elements of an
--- iterator, then concatenates all the results into a single
--- iterator.
---
--- @function fun.tuples(fun, iter)
--- @tparam function(...=>list) fun
--- @tparam iterator(table) iter
--- @treturn iterator(...)
local flatmap = function(fun, gen, param, state)
    local all = map(fun, gen, param, state):totable()
    return chain(unpack(all))
end
methods.flatmap = method1(flatmap)
exports.flatmap = export1(flatmap)

local each_with_self = function(the_self, field, gen, param, state)
   return each(function(...) return the_self[field](the_self, ...) end, gen, param, state)
end
methods.each_with_self = method2(each_with_self)
exports.each_with_self = export2(each_with_self)

local select_retval = function(n, gen, param, state)
   return map(function(...) return select(n, ...) end, gen, param, state)
end
methods.select_retval = method1(select_retval)
exports.select_retval = export1(select_retval)

local group_by = function(f, default, gen, param, state)
   if type(f) ~= "function" then
      f = function(i)
         return i[f] or default
      end
   end

   local function group_by_x(acc, x)
      local field = f(x)
      acc[field] = acc[field] or {}
      table.insert(acc[field], x)
      return acc
   end
   return foldl(group_by_x, {}, gen, param, state)
end
methods.group_by = method2(group_by)
exports.group_by = export2(group_by)

local function dup_helper(n, var_1, ...)
   if var_1 ~= nil then
      return var_1, select(n, var_1, ...), ...
   end
end

--- Duplicates iterators that return only a single value per iteration
--- (like string.gmatch) so they can be used with fun.wrap().
---
--- From https://github.com/luafun/luafun/issues/20#issuecomment-207777263
---
--- @function fun.dup(n, f, s, var)
--- @tparam any n gen
--- @tparam any f param
--- @tparam any s state
--- @tparam any var
--- @treturn iterator
local dup = function(n, f, s, var)
   if type( n ) ~= "number" then
      n, f, s, var = 1, n, f, s
   end
   return function(s2, v)
      return dup_helper(n, f(s2, v))
   end, s, var
end
exports.dup = dup

--- Force the iteration of a table as a sparse key-value map.
local iter_pairs = function(obj)
   return wrap(kv_iter_gen, obj, nil)
end
exports.iter_pairs = iter_pairs

--- Unwraps this iterator as a list, allocating a new table, and
--- returns a new iterator in sorted order.
---
--- As it uses table.sort internally, the sort is not stable.
local into_sorted = function(comparator, gen, param, state)
   local list = totable(gen, param, state)
   table.sort(list, comparator)
   return iter(list)
end
methods.into_sorted = method1(into_sorted)
exports.into_sorted = export1(into_sorted)

return exports
