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
-- @treturn array|table an array or an associated array where tblA and tblB have been merged
function table.merge(tblA, tblB)
   if not tblB then
      return tblA
   end
   for k, v in pairs(tblB) do
      tblA[k] = v
   end
   return tblA
end

function table.imerge(tblA, tblB)
   if not tblB then
      return tblA
   end
   for _, v in ipairs(tblB) do
      table.insert(tblA, v)
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

--- Merges two tables, where keys from b that are not in a will have
--- their values discarded.
-- @tparam table a
-- @tparam table b
-- @treturn table
function table.merge_existing(a, b)
   if not b then
      return a
   end

   for k, v in pairs(b) do
      if a[k] ~= nil then
         a[k] = v
      end
   end

   return a
end

--- Replaces one table with another such that existing
--- globals/upvalues pointing to the table will also be updated
--- in-place.
-- @tparam table tbl
-- @tparam table other
-- @treturn table
function table.replace_with(tbl, other)
   if tbl == other then
      return tbl
   end

   for k, _ in pairs(tbl) do
      tbl[k] = nil
   end

   for k, v in pairs(other) do
      tbl[k] = v
   end

   return tbl
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

function table.copy(tbl)
   local new = {}
   for k, v in pairs(tbl) do
      new[k] = v
   end
   return new
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

function table.iremove_value(tbl, value)
   local result

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

table.unpack = unpack

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

-- Returns the keys of a dictionary-like table.
-- @tparam table tbl
-- @treturn array
function table.keys(tbl)
   local arr = {}
   for k, _ in pairs(tbl) do
      arr[#arr+1] = k
   end
   return arr
end

-- Returns the values of a dictionary-like table.
-- @tparam table tbl
-- @treturn array
function table.values(tbl)
   local arr = {}
   for _, v in pairs(tbl) do
      arr[#arr+1] = v
   end
   return arr
end

--- Removes the specified indices from an array-like table. The
--- indices must be an array of integers with no duplicates sorted in
--- ascending order.
function table.remove_indices(arr, inds)
   local offset = 0
   for _, ind in ipairs(inds) do
      table.remove(arr, ind-offset)
      offset = offset + 1
   end
   return arr
end

function table.remove_by(arr, f)
   local inds = {}
   for i, v in ipairs(arr) do
      if f(v) then
         inds[#inds+1] = i
      end
   end
   return table.remove_indices(arr, inds)
end

local function right_pad(str, len)
   return str .. string.rep(' ', len - #str)
end

local function ireduce(arr, f, start)
   local result = start

   for _, v in ipairs(arr) do
      result = f(result, v)
   end

   return result
end

--- Formats a 2-dimensional array-like table in a printable manner.
-- @tparam array t
-- @tparam[opt] array params.header
-- @tparam[opt] array params.spacing
-- @tparam[opt] array params.sort
-- @treturn string
function table.print(t, params)
   if not (t[1] ~= nil and t[1][1] ~= nil) then
      return "(empty)"
   end

   local columns = #t[1]
   local widths = table.of(0, columns)
   local spacing = params.spacing or 1

   if params.sort then
      table.sort(t, function(a, b) return a[params.sort] < b[params.sort] end)
   end

   if params.header then
      for j, item in ipairs(params.header) do
         widths[j] = math.max(widths[j], utf8.wide_len(item) + spacing)
      end
   end

   for i, row in ipairs(t) do
      for j, item in ipairs(row) do
         widths[j] = math.max(widths[j], utf8.wide_len(tostring(item)) + spacing)
      end
   end

   local total_width = ireduce(widths, function(sum, n) return sum + n + 1 end, 0)

   local s = ""

   if params.header then
      for j, item in ipairs(params.header) do
         s = s .. string.format("%s", right_pad(item, widths[j] + spacing))
      end
      s = s .. "\n" .. string.rep('-', total_width) .. "\n"
   end

   for i, row in ipairs(t) do
      for j, item in ipairs(row) do
         s = s .. string.format("%s", right_pad(tostring(item), widths[j] + spacing))
      end
      s = s .. "\n"
   end

   return s
end

--- Sorts a table in O(n^2) time in a stable manner. Ported from Elona
--- 1.22 to preserve correctness.
-- @tparam array arr
-- @tparam[opt] func f
function table.insertion_sort(arr, f)
   local found_unsorted = true

   if f == nil then
      f = function(a, b) return a > b end
   end

   local last = #arr - 1
   while found_unsorted do
      found_unsorted = false

      for i=1,last do
         local va, vb = arr[i], arr[i+1]
         if f(vb, va) then
            arr[i] = vb
            arr[i+1] = va
            found_unsorted = true
         end
      end

      last = last - 1
   end
end


local function mod_value(tbl, add, meth, default, prop)
   if default and tbl[prop] == nil then
      tbl[prop] = default[prop]
   end
   if meth == "add" then
      local _type = type(add)
      if _type == "boolean" or _type == "string" then
         tbl[prop] = tbl[prop] or add
      else
         tbl[prop] = (tbl[prop] or 0) + add
      end
   elseif meth == "set" or meth == "replace" then
      tbl[prop] = add
   elseif meth == "merge" then
      if not tbl[prop] then
         tbl[prop] = add
      end
   else
      error("unknown merge method " .. meth)
   end
end

function table.merge_ex_single(base, value, meth, default, key)
   assert(type(base) == "table", key)

   if type(value) == "table" then
      if value.__method then
         -- specific method
         meth = value.__method
         value = value.__value
      end
   end

   if type(value) == "table" and meth ~= "replace" then
      -- Actual table
      if base[key] == nil then
         if default and default[key] then
            base[key] = table.deepcopy(default[key])
         else
            base[key] = {}
         end
      end
      for k, v in pairs(value) do
         table.merge_ex_single(base[key], v, meth, default and default[key], k)
      end
   else
      mod_value(base, value, meth, default, key)
   end

   return base
end

--- Configurable merge. Individual values can be merged in specific
--- ways by annotating them with the special __method and __value
--- fields.
-- @tparam table tbl Table to merge values onto.
-- @tparam any add Value to merge. If the field __multi is non-nil,
-- treat this table as an array, each containing another table to run
-- merge_ex on in the order listed.
-- @tparam[opt] table defaults Default table to take values from if any
-- are missing in `tbl` but present in `add`.
-- @tparam[opt] string method Merge method. Supported methods are:
-- set: sets values to a fixed amount. (default)
-- add: adds values. For non-number values, same as `set`.
-- merge: same as `set`, but do not overwrite values already existing.
-- replace: do not attempt to merge tables, only assign.
-- in `tbl`.
function table.merge_ex(tbl, add, defaults, method)
   assert(type(tbl) == "table")
   method = method or "set"

   if add.__multi then
      for _, t in ipairs(add) do
         table.merge_ex(tbl, t, defaults, method)
      end
   else
      for k, v in pairs(add) do
         table.merge_ex_single(tbl, v, method, defaults, k)
      end
   end

   return tbl
end
