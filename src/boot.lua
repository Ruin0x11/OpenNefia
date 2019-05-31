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

function table.of(item, count)
   local tbl = {}
   if type(item) == "function" then
      for i=0,count do
         tbl[#tbl+1] = item(i)
      end
   else
      for i=0,count do
         tbl[#tbl+1] = item
      end
   end
   return tbl
end

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
print(tostring(interface))
class = class_.class

if not love then
   _DEBUG = true
   love = require("util.automagic")()

   love.graphics.getWidth = function() return 800 end
   love.graphics.getHeight = function() return 600 end
   love.graphics.getFont = function()
      return
         {
            getWidth = function(s) return #s * 8 end,
            getHeight = function() return 14 end,
         }
   end
   love.graphics.setFont = function() end
   love.graphics.setColor = function() end
   love.graphics.setBlendMode = function() end
   love.graphics.line = function() end
   love.graphics.polygon = function() end
   love.graphics.print = function() end
   love.graphics.newSpriteBatch = function()
      return {
         clear = function() end,
         add = function() end,
         flush = function() end,
      }
   end
   love.graphics.newQuad = function()
      return {
         getViewport = function() return 0, 0, 100, 100 end
      }
   end
   love.graphics.newFont = function()
      return {}
   end
   love.graphics.newImage = function()
      return {
         getWidth = function() return 100 end,
         getHeight = function() return 100 end,
         setFilter = function() end,
      }
   end
   love.graphics.draw = function() end
   love.image.newImageData = function(fn)
      return {
         mapPixel = function() end
      }
   end
   love.keyboard.setKeyRepeat = function() end
   print("ty", type(love.graphics.getWidth))
end

function _p(it)
   print(inspect(it))
   return it
end

-- prevent new globals from here on out.

local function deny(t, k, v)
   if type(v) ~= "function" then
      local trace = debug.traceback()
      local err = string.format("Globals are not allowed. (%s : %s)\n\t%s", tostring(k), tostring(v), trace)
      error(err)
   end
   rawset(t, k, v)
end

setmetatable(_G, {__newindex = deny})
