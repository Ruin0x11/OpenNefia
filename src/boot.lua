package.path = package.path .. ";./thirdparty/?.lua;./?/init.lua"

-- globals that will be used very often.

_DEBUG = false

function string.nonempty(s)
   return type(s) == "string" and s ~= ""
end

function math.clamp(i, min, max)
   return math.min(max, math.max(min, i))
end

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

--- Creates a deep copy of table without copying userdata objects.
-- @tparam table object the table to copy
-- @treturn table a copy of the table
function table.deepcopy(object)
   local lookup_table = {}
   local function _copy(this_object)
      if type(this_object) ~= "table" then
         return this_object
      elseif this_object.__self then
         return this_object
      elseif lookup_table[this_object] then
         return lookup_table[this_object]
      end
      local new_table = {}
      lookup_table[this_object] = new_table
      for index, value in pairs(this_object) do
         new_table[_copy(index)] = _copy(value)
      end
      return setmetatable(new_table, getmetatable(this_object))
   end
   return _copy(object)
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

function table.pop(tbl)
   local it = tbl[#tbl]
   tbl[#tbl] = nil
   return it
end

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

local function try_require(mod)
   local success, obj = pcall(function() return require(mod) end)
   if success then
      return obj
   end

   return nil
end

utf8 = try_require("utf8")
if love == nil and (utf8 == nil or utf8.codes == nil) then
   -- require the luarocks version (starwing/utf8)
   utf8 = require("lua-utf8")
end

--- Returns a new string with the last UTF-8 codepoint removed.
-- @tparam string t
-- @treturn string
function utf8.pop(t)
   local byteoffset = utf8.offset(t, -1)

   if byteoffset then
      t = string.sub(t, 1, byteoffset - 1)
   end

   return t
end

--- Analogous to string.sub, but operates on UTF-8 codepoints.
-- @see string.sub
-- @tparam string t
-- @tparam int i
-- @tparam int j
-- @treturn string
function utf8.sub(t, i, j)
   local len = utf8.len(t)

   local start = utf8.offset(t, i) or 0
   local finish = (utf8.offset(t, j + 1) or (#t + 1)) - 1

   return string.sub(t, start, finish)
end

-- Returns true if cp is a fullwidth UTF-8 codepoint.
--
-- NOTE: This function isn't completely accurate. It ought to use the
-- UCD East Asian Width table instead.
-- (https://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt)
--
-- @tparam int cp utf8 codepoint
-- @treturn bool
function utf8.is_fullwidth(cp)
   if cp < 0x2e80 then      -- Standard
      return false
   elseif cp < 0xa700 then  -- Japanese, Korean, CJK
      return true
   elseif cp < 0xac00 then  -- Modified Tone Letters, Syloti Nagri
      return false
   elseif cp < 0xd800 then  -- Hangul Syllables
      return true
   elseif cp < 0xf900 then  -- (non-fullwidth)
      return false
   elseif cp < 0xfb00 then  -- CJK
      return true
   elseif cp < 0xfe20 then  -- (non-fullwidth)
      return false
   elseif cp < 0xfe70 then  -- CJK
      return true
   elseif cp < 0xff00 then  -- (non-fullwidth)
      return false
   elseif cp < 0xff61 then  -- Fullwidth forms
      return true
   elseif cp < 0xffe0 then  -- Halfwidth forms
      return false
   elseif cp < 0xffe8 then  -- Fullwidth forms
      return true
   elseif cp < 0x20000 then -- (non-fullwidth)
      return false
   elseif cp < 0xe0000 then -- CJK
      return true
   end

   return false
end

--- Returns the length of the string in terms of widthness. Halfwidth
--- counts as 1, fullwidth 2.
-- @tparam string t
-- @treturn int
function utf8.wide_len(t)
   local len = 0
   for p, c in utf8.codes(t) do
      if utf8.is_fullwidth(c) then
         len = len + 2
      else
         len = len + 1
      end
   end
   return len
end

--- Analogous to string.sub, but operates on the widthness of
--- characters. Halfwidth counts as length 1, fullwidth 2.
-- @see string.sub
-- @tparam string t
-- @tparam int i
-- @tparam int j
-- @treturn string
function utf8.wide_sub(t, i, j)
   local start, finish, len

   if not i then
      start = 0
      i = 0
   end
   if not j then
      finish = #t
      j = 0
   end

   for p, c in utf8.codes(t) do
      if not start and i <= 0 then start = p end
      if not finish and j < 0 then finish = p-1 end
      if start and finish then break end

      if utf8.is_fullwidth(c) then
         len = 2
      else
         len = 1
      end
      i = i - len
      j = j - len
   end

   return string.sub(t, start, finish)
end

mobdebug = require("mobdebug")
mobdebug.is_running = function()
   local _, mask = debug.gethook(coroutine.running())
   return mask == "crl"
end
mobdebug.scope = function(f)
   local set = false
   if _DEBUG and mobdebug.is_running() then
      set = true
      mobdebug.off()
   end

   f()

   if set then
      mobdebug.on()
   end
end

inspect = require("inspect")

local class_ = require("util.class")
interface = class_.interface
class = class_.class

if not love then
   _DEBUG = true
   love = require("util.lovemock")
end

function _p(it)
   print(inspect(it))
   return it
end

-- prevent new globals from here on out.
require("thirdparty.strict")
