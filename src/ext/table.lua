--- Given a candidate search function, iterates over the table, calling the function
--- for each element in the table, and returns the first element the search function returned true.
--- Passes the index as second argument to the function.
--- @usage a= { 1, 2, 3, 4, 5}
---table.find(a, function(v) return v % 2 == 0 end) --produces: 2
--- @usage a = {1, 2, 3, 4, 5}
---table.find(a, function(v, k, x) return k % 2 == 1 end) --produces: 1
-- @tparam table tbl the table to be searched
-- @tparam function func the function to use to search for any matching element
-- @param[opt] ... additional arguments passed to the function
-- @treturn ?|nil|Mixed the first found value, or nil if none was found
function table.find(tbl, func, ...)
   for k, v in pairs(tbl) do
      if func(v, k, ...) then
         return v, k
      end
   end
   return nil
end

--- Merges two tables &mdash; values from first get overwritten by the second.
--- @usage
-- function some_func(x, y, args)
--     args = table.merge({option1=false}, args)
--     if opts.option1 == true then return x else return y end
-- end
-- some_func(1,2) -- returns 2
-- some_func(1,2,{option1=true}) -- returns 1
-- @tparam table tblA first table
-- @tparam table tblB second table
-- @tparam[opt=false] boolean array_merge set to true to merge the tables as an array or false for an associative array
-- @treturn array|table an array or an associated array where tblA and tblB have been merged
function table.merge(tblA, tblB, array_merge)
   if not tblB then
      return tblA
   end
   if array_merge then
      for _, v in pairs(tblB) do
         table.insert(tblA, v)
      end

   else
      for k, v in pairs(tblB) do
         tblA[k] = v
      end
   end
   return tblA
end

--- Merges two tables, where values from b are overridden by values
--- already in a.
-- @tparam table a
-- @tparam table b
-- @treturn table
function table.merge_missing(a, b)
   if not b then
      return a
   end

   for k, v in pairs(b) do
      if a[k] == nil then
         a[k] = v
      end
   end

   return a
end

local function cycle_aware_copy(t, cache)
    if type(t) ~= 'table' then return t end
    if cache[t] then return cache[t] end
    local res = {}
    cache[t] = res
    local mt = getmetatable(t)
    for k,v in pairs(t) do
        k = cycle_aware_copy(k, cache)
        v = cycle_aware_copy(v, cache)
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end

--- make a deep copy of a table, recursively copying all the keys and fields.
-- This supports cycles in tables; cycles will be reproduced in the copy.
-- This will also set the copied table's metatable to that of the original.
-- @within Copying
-- @tab t A table
-- @return new table
function table.deepcopy(t)
    return cycle_aware_copy(t,{})
end

local abs = math.abs

local function cycle_aware_compare(t1,t2,ignore_mt,eps,cache)
    if cache[t1] and cache[t1][t2] then return true end
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' then
        if ty1 == 'number' and eps then return abs(t1-t2) < eps end
        return t1 == t2
    end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1 in pairs(t1) do
        if t2[k1]==nil then return false end
    end
    for k2 in pairs(t2) do
        if t1[k2]==nil then return false end
    end
    cache[t1] = cache[t1] or {}
    cache[t1][t2] = true
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if not cycle_aware_compare(v1,v2,ignore_mt,eps,cache) then return false end
    end
    return true
end

--- compare two values.
-- if they are tables, then compare their keys and fields recursively.
-- @within Comparing
-- @param t1 A value
-- @param t2 A value
-- @bool[opt] ignore_mt if true, ignore __eq metamethod (default false)
-- @number[opt] eps if defined, then used for any number comparisons
-- @return true or false
function table.deepcompare(t1,t2,ignore_mt,eps)
    return cycle_aware_compare(t1,t2,ignore_mt,eps,{})
end

--- Returns true if the table contains a given value.
-- @tparam table tbl the table to search
-- @param value the value to search for
function table.contains(tbl, value)
   local function predicate(v)
      return v == value
   end
   return table.find(tbl, predicate)
end

--- Returns the number of items in a dictionary-like table.
-- @tparam table tbl
-- @treturn int
function table.count(tbl)
   local count = 0
   for _, _ in pairs(tbl) do
      count = count + 1
   end
   return count
end


--- Produces a table of count references of item.
-- @tparam any item
-- @tparam int count
-- @treturn table
function table.of(item, count)
   local tbl = {}
   if type(item) == "function" then
      for i=1,count do
         tbl[#tbl+1] = item(i)
      end
   else
      for i=1,count do
         tbl[#tbl+1] = item
      end
   end
   return tbl
end

function table.of_2d(item, width, height, zero_indexed)
   local tbl = {}
   local add = 0
   if zero_indexed then
      add = -1
   end
   if type(item) == "function" then
      for j=1+add,height+add do
         tbl[j] = {}
         for i=1+add,width+add do
            tbl[j][i] = item(i, j)
         end
      end
   else
      for j=1+add,height+add do
         tbl[j] = {}
         for i=1+add,width+add do
            tbl[j][i] = item
         end
      end
   end
   return tbl
end

function table.remove_value(tbl, value, array)
   local result

   if array then
      local ind
      for i, v in ipairs(tbl) do
         if v == value then
            ind = i
            break
         end
      end
      if ind then
         result = table.remove(tbl, ind)
      end
   else
      for k, v in pairs(tbl) do
         if v == value then
            ind = k
            result = v
            break
         end
      end
      tbl[k] = nil
   end

   return result
end

--- Maps a function over tbl.
-- @tparam table tbl
-- @tparam func f
-- @tparam bool array set to true if tbl is an array
-- @treturn table
function table.map(tbl, f, array)
   local t = {}
   if array then
      for i, v in ipairs(tbl) do
         t[i] = f(v)
      end
   else
      for k, v in pairs(tbl) do
         t[k] = f(v)
      end
   end
   return t
end

--- Reduces an array-like table over a function.
-- @tparam array arr
-- @tparam func f
-- @tparam any start
-- @treturn any
function table.reduce(arr, f, start)
   local result = start

   for _, v in ipairs(arr) do
      result = f(result, v)
   end

   return result
end

--- Flattens an array-like table one layer down.
-- @tparam array arr
-- @treturn array
function table.flatten(arr)
   local result = {}

   local function flatten(arr)
      for _, v in ipairs(arr) do
         table.insert(result, v)
      end
   end

   for _, v in ipairs(arr) do
      flatten(v)
   end

   return result
end

table.push = table.insert

table.unpack = unpack
unpack = nil

--- Tries to obtain a nested value in a table.
-- @tparam table obj
-- @param ... a list of keys
-- @treturn[1] any
-- @treturn[2] nil
function table.maybe(obj, ...)
   local arg = {...}
   local len = #arg
   local t = obj
   for i, k in ipairs(arg) do
      if not t then
         return nil
      end
      if i > len then break end
      t = t[k]
   end
   return t
end

--- Concatenates two array-like tables.
-- @tparam array a
-- @tparam array b
-- @treturn array
function table.append(a, b)
   for _, v in ipairs(b) do
      table.insert(a, v)
   end
   return a
end

--- Converts an array to a set, with all keys set to "true".
-- @tparam array arr
-- @treturn table
function table.set(arr)
   local tbl = {}
   for _, k in ipairs(arr) do
      tbl[k] = true
   end
   return tbl
end
