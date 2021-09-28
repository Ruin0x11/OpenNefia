-- binser.lua

--[[
   Copyright (c) 2016-2019 Calvin Rose

   Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
   the Software, and to permit persons to whom the Software is furnished to do so,
   subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
   FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
   IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local assert = assert
local error = error
local select = select
local pairs = pairs
local getmetatable = getmetatable
local setmetatable = setmetatable
local type = type
local loadstring = loadstring or load
local concat = table.concat
local char = string.char
local byte = string.byte
local format = string.format
local sub = string.sub
local dump = string.dump
local floor = math.floor
local frexp = math.frexp
local unpack = unpack or table.unpack

-- Lua 5.3 frexp polyfill
-- From https://github.com/excessive/cpml/blob/master/modules/utils.lua
if not frexp then
   local log, abs, floor = math.log, math.abs, math.floor
   local log2 = log(2)
   frexp = function(x)
      if x == 0 then return 0, 0 end
      local e = floor(log(abs(x)) / log2 + 1)
      return x / 2 ^ e, e
   end
end

local function pack(...)
   return {...}, select("#", ...)
end

local function not_array_index(x, len)
   return type(x) ~= "number" or x < 1 or x > len or x ~= floor(x)
end

local function type_check(x, tp, name)
   assert(type(x) == tp,
          format("Expected parameter %q to be of type %q.", name, tp))
end

local bigIntSupport = false
local isInteger
if _VERSION == "Lua 5.3" then -- Detect Lua 5.3
   local mtype = math.type
   bigIntSupport = loadstring[[
    local char = string.char
    return function(n)
        local nn = n < 0 and -(n + 1) or n
        local b1 = nn // 0x100000000000000
        local b2 = nn // 0x1000000000000 % 0x100
        local b3 = nn // 0x10000000000 % 0x100
        local b4 = nn // 0x100000000 % 0x100
        local b5 = nn // 0x1000000 % 0x100
        local b6 = nn // 0x10000 % 0x100
        local b7 = nn // 0x100 % 0x100
        local b8 = nn % 0x100
        if n < 0 then
            b1, b2, b3, b4 = 0xFF - b1, 0xFF - b2, 0xFF - b3, 0xFF - b4
            b5, b6, b7, b8 = 0xFF - b5, 0xFF - b6, 0xFF - b7, 0xFF - b8
        end
        return char(212, b1, b2, b3, b4, b5, b6, b7, b8)
    end]]()
    isInteger = function(x)
       return mtype(x) == 'integer'
    end
else
   isInteger = function(x)
      return floor(x) == x
   end
end

-- Copyright (C) 2012-2015 Francois Perrad.
-- number serialization code modified from https://github.com/fperrad/lua-MessagePack
-- Encode a number as a big-endian ieee-754 double, big-endian signed 64 bit integer, or a small integer
local function number_to_str(n)
   if isInteger(n) then -- int
      if n <= 100 and n >= -27 then -- 1 byte, 7 bits of data
         return char(n + 27)
      elseif n <= 8191 and n >= -8192 then -- 2 bytes, 14 bits of data
         n = n + 8192
         return char(128 + (floor(n / 0x100) % 0x100), n % 0x100)
      elseif bigIntSupport then
         return bigIntSupport(n)
      end
   end
   local sign = 0
   if n < 0.0 then
      sign = 0x80
      n = -n
   end
   local m, e = frexp(n) -- mantissa, exponent
   if m ~= m then
      return char(203, 0xFF, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
   elseif m == 1/0 then
      if sign == 0 then
         return char(203, 0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
      else
         return char(203, 0xFF, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
      end
   end
   e = e + 0x3FE
   if e < 1 then -- denormalized numbers
      m = m * 2 ^ (52 + e)
      e = 0
   else
      m = (m * 2 - 1) * 2 ^ 52
   end
   return char(203,
               sign + floor(e / 0x10),
               (e % 0x10) * 0x10 + floor(m / 0x1000000000000),
               floor(m / 0x10000000000) % 0x100,
               floor(m / 0x100000000) % 0x100,
               floor(m / 0x1000000) % 0x100,
               floor(m / 0x10000) % 0x100,
               floor(m / 0x100) % 0x100,
               m % 0x100)
end

-- Copyright (C) 2012-2015 Francois Perrad.
-- number deserialization code also modified from https://github.com/fperrad/lua-MessagePack
local function number_from_str(str, index)
   local b = byte(str, index)
   if not b then error("Expected more bytes of input.") end
   if b < 128 then
      return b - 27, index + 1
   elseif b < 192 then
      local b2 = byte(str, index + 1)
      if not b2 then error("Expected more bytes of input.") end
      return b2 + 0x100 * (b - 128) - 8192, index + 2
   end
   local b1, b2, b3, b4, b5, b6, b7, b8 = byte(str, index + 1, index + 8)
   if (not b1) or (not b2) or (not b3) or (not b4) or
      (not b5) or (not b6) or (not b7) or (not b8) then
      error("Expected more bytes of input.")
   end
   if b == 212 then
      local flip = b1 >= 128
      if flip then -- negative
         b1, b2, b3, b4 = 0xFF - b1, 0xFF - b2, 0xFF - b3, 0xFF - b4
         b5, b6, b7, b8 = 0xFF - b5, 0xFF - b6, 0xFF - b7, 0xFF - b8
      end
      local n = ((((((b1 * 0x100 + b2) * 0x100 + b3) * 0x100 + b4) *
               0x100 + b5) * 0x100 + b6) * 0x100 + b7) * 0x100 + b8
      if flip then
         return (-n) - 1, index + 9
      else
         return n, index + 9
      end
   end
   if b ~= 203 then
      error("Expected number")
   end
   local sign = b1 > 0x7F and -1 or 1
   local e = (b1 % 0x80) * 0x10 + floor(b2 / 0x10)
   local m = ((((((b2 % 0x10) * 0x100 + b3) * 0x100 + b4) * 0x100 + b5) * 0x100 + b6) * 0x100 + b7) * 0x100 + b8
   local n
   if e == 0 then
      if m == 0 then
         n = sign * 0.0
      else
         n = sign * (m / 2 ^ 52) * 2 ^ -1022
      end
   elseif e == 0x7FF then
      if m == 0 then
         n = sign * (1/0)
      else
         n = 0.0/0.0
      end
   else
      n = sign * (1.0 + m / 2 ^ 52) * 2 ^ (e - 0x3FF)
   end
   return n, index + 9
end

local RESERVED_IDS = {
   ["object"] = true,
   ["data_entry"] = true
}

local function newbinser()

   -- unique table key for getting next value
   local NEXT = {}
   local CTORSTACK = {}
   local PENDING_CLASS_OBJS = {}

   -- NIL = 202
   -- FLOAT = 203
   -- TRUE = 204
   -- FALSE = 205
   -- STRING = 206
   -- TABLE = 207
   -- REFERENCE = 208
   -- CONSTRUCTOR = 209
   -- FUNCTION = 210
   -- RESOURCE = 211
   -- INT64 = 212
   -- TABLE WITH META = 213
   -- OBJECT/MAP OBJECT = 214
   -- CLASS OBJECT = 215

   local mts = {}
   local serializers = {}
   local deserializers = {}
   local classes = {}
   local serial_ids = {}
   local types = {}

   types["nil"] = function(x, visited, accum)
      accum[#accum + 1] = "\202"
   end

   function types.number(x, visited, accum)
      accum[#accum + 1] = number_to_str(x)
   end

   function types.boolean(x, visited, accum)
      accum[#accum + 1] = x and "\204" or "\205"
   end

   function types.string(x, visited, accum)
      local alen = #accum
      if visited[x] then
         accum[alen + 1] = "\208"
         accum[alen + 2] = number_to_str(visited[x])
      else
         visited[x] = visited[NEXT]
         visited[NEXT] =  visited[NEXT] + 1
         accum[alen + 1] = "\206"
         accum[alen + 2] = number_to_str(#x)
         accum[alen + 3] = x
      end
   end

   local function check_custom_type(x, visited, accum)
      -- local res = resources[x]
      -- if res then
      --     accum[#accum + 1] = "\211"
      --     types[type(res)](res, visited, accum)
      --     return true
      -- end

      local mt = getmetatable(x)
      local serial_id = mt and mt.__serial_id
      if serial_id == "object" then
         accum[#accum + 1] = "\214"

         types[type(serial_id)](serial_id, visited, accum)
         local args, len = pack(serializers["object"](x))
         accum[#accum + 1] = number_to_str(len)
         for i = 1, len do
            local arg = args[i]
            types[type(arg)](arg, visited, accum)
         end
         visited[x] = visited[NEXT]
         visited[NEXT] = visited[NEXT] + 1

         return true
      elseif mt and serial_ids[mt] and serializers[serial_ids[mt]] then
         local id = serial_ids[mt]
         local constructing = visited[CTORSTACK]
         if constructing[x] then
            error("Infinite loop in constructor.")
         end
         constructing[x] = true
         accum[#accum + 1] = "\209"
         types[type(id)](id, visited, accum)
         local args, len = pack(serializers[id](x))
         accum[#accum + 1] = number_to_str(len)
         for i = 1, len do
            local arg = args[i]
            types[type(arg)](arg, visited, accum)
         end
         visited[x] = visited[NEXT]
         visited[NEXT] = visited[NEXT] + 1
         -- We finished constructing
         constructing[x] = nil
         return true
      elseif mt and mt.__class then
         if not serial_id then
            error("Cannot serialize class of type " .. tostring(x) .. ": Class has no __serial_id declared")
         end
         local klass = classes[serial_id]
         if not klass then
            error("Cannot serialize class of type " .. tostring(x) .. ": Class was not registered as ISerializable")
         end
         local constructing = visited[CTORSTACK]
         if constructing[x] then
            error("Cannot serialize class of type " .. tostring(x) .. ": Infinite loop in constructor")
         end
         constructing[x] = true
         accum[#accum + 1] = "\215"
         types[type(serial_id)](serial_id, visited, accum)
         local args, len = pack(mt.serialize(x))

         local memoized = x.__memoized
         local mt = getmetatable(x)
         setmetatable(x, nil)
         x.__memoized = {}

         accum[#accum + 1] = number_to_str(len)
         for i = 1, len do
            local arg = args[i]
            types[type(arg)](arg, visited, accum)
         end

         x.__memoized = memoized
         setmetatable(x, mt)

         visited[x] = visited[NEXT]
         visited[NEXT] = visited[NEXT] + 1
         -- We finished constructing
         constructing[x] = nil
         return true
      end
   end

   function types.userdata(x, visited, accum)
      if visited[x] then
          accum[#accum + 1] = "\208"
          accum[#accum + 1] = number_to_str(visited[x])
      else
          if check_custom_type(x, visited, accum) then return end
          error("Cannot serialize this userdata.")
      end
   end

   function types.table(x, visited, accum)
      if visited[x] then
         accum[#accum + 1] = "\208"
         accum[#accum + 1] = number_to_str(visited[x])
      else
         if check_custom_type(x, visited, accum) then return end
         visited[x] = visited[NEXT]
         visited[NEXT] =  visited[NEXT] + 1
         local xlen = #x
         local mt = getmetatable(x)
         if mt then
            accum[#accum + 1] = "\213"
            types.table(mt, visited, accum)
         else
            accum[#accum + 1] = "\207"
         end
         accum[#accum + 1] = number_to_str(xlen)
         for i = 1, xlen do
            local v = x[i]
            types[type(v)](v, visited, accum)
         end
         local key_count = 0
         for k in pairs(x) do
            if not_array_index(k, xlen) then
               key_count = key_count + 1
            end
         end
         accum[#accum + 1] = number_to_str(key_count)
         for k, v in pairs(x) do
            if not_array_index(k, xlen) then
               types[type(k)](k, visited, accum)
               types[type(v)](v, visited, accum)
            end
         end
      end
   end

   types["function"] = function(x, visited, accum)
      if visited[x] then
          accum[#accum + 1] = "\208"
          accum[#accum + 1] = number_to_str(visited[x])
      else
          error("Cannot serialize functions.")
      end
   end

   types.cdata = function(x, visited, accum)
      if visited[x] then
          accum[#accum + 1] = "\208"
          accum[#accum + 1] = number_to_str(visited[x])
      else
          if check_custom_type(x, visited, #accum) then return end
          error("Cannot serialize this cdata.")
      end
   end

   types.thread = function() error("Cannot serialize threads.") end

   local function deserialize_value(str, index, visited)
      local t = byte(str, index)
      if not t then return nil, index end
      if t < 128 then
         return t - 27, index + 1
      elseif t < 192 then
         local b2 = byte(str, index + 1)
         if not b2 then error("Expected more bytes of input.") end
         return b2 + 0x100 * (t - 128) - 8192, index + 2
      elseif t == 202 then
         return nil, index + 1
      elseif t == 203 or t == 212 then
         return number_from_str(str, index)
      elseif t == 204 then
         return true, index + 1
      elseif t == 205 then
         return false, index + 1
      elseif t == 206 then
         local length, dataindex = number_from_str(str, index + 1)
         local nextindex = dataindex + length
         if not (length >= 0) then error("Bad string length") end
         if #str < nextindex - 1 then error("Expected more bytes of string") end
         local substr = sub(str, dataindex, nextindex - 1)
         visited[#visited + 1] = substr
         return substr, nextindex
      elseif t == 207 or t == 213 then
         local mt, count, nextindex
         local ret = {}
         visited[#visited + 1] = ret
         nextindex = index + 1
         if t == 213 then
            mt, nextindex = deserialize_value(str, nextindex, visited)
            if type(mt) ~= "table" then error("Expected table metatable") end
         end
         count, nextindex = number_from_str(str, nextindex)
         for i = 1, count do
            local oldindex = nextindex
            ret[i], nextindex = deserialize_value(str, nextindex, visited)
            if nextindex == oldindex then error("Expected more bytes of input.") end
         end
         count, nextindex = number_from_str(str, nextindex)
         for i = 1, count do
            local k, v
            local oldindex = nextindex
            k, nextindex = deserialize_value(str, nextindex, visited)
            if nextindex == oldindex then error("Expected more bytes of input.") end
            oldindex = nextindex
            v, nextindex = deserialize_value(str, nextindex, visited)
            if nextindex == oldindex then error("Expected more bytes of input.") end
            if k == nil then error("Can't have nil table keys") end
            ret[k] = v
         end
         if mt then setmetatable(ret, mt) end
         return ret, nextindex
      elseif t == 208 then
         local ref, nextindex = number_from_str(str, index + 1)
         return visited[ref], nextindex
      elseif t == 209 then
         local count
         local name, nextindex = deserialize_value(str, index + 1, visited)
         count, nextindex = number_from_str(str, nextindex)
         local args = {}
         for i = 1, count do
            local oldindex = nextindex
            args[i], nextindex = deserialize_value(str, nextindex, visited)
            if nextindex == oldindex then error("Expected more bytes of input.") end
         end
         if not name or not deserializers[name] then
            error(("Cannot deserialize class '%s'"):format(tostring(name)))
         end
         local ret = deserializers[name](unpack(args))
         visited[#visited + 1] = ret
         return ret, nextindex
      elseif t == 210 then
         local length, dataindex = number_from_str(str, index + 1)
         local nextindex = dataindex + length
         if not (length >= 0) then error("Bad string length") end
         if #str < nextindex - 1 then error("Expected more bytes of string") end
         local ret = loadstring(sub(str, dataindex, nextindex - 1))
         visited[#visited + 1] = ret
         return ret, nextindex
         -- elseif t == 211 then
         --     local resname, nextindex = deserialize_value(str, index + 1, visited)
         --     if resname == nil then error("Got nil resource name") end
         --     local res = resources_by_name[resname]
         --     if res == nil then
         --         error(("No resources found for name '%s'"):format(tostring(resname)))
         --     end
         --     return res, nextindex
      elseif t == 215 then
         local count
         local serial_id, nextindex = deserialize_value(str, index + 1, visited)
         count, nextindex = number_from_str(str, nextindex)
         local args = {}
         for i = 1, count do
            local oldindex = nextindex
            args[i], nextindex = deserialize_value(str, nextindex, visited)
            if nextindex == oldindex then error("Expected more bytes of input.") end
         end
         if not serial_id or not classes[serial_id] then
            error(("Cannot deserialize class with serial ID '%s'"):format(tostring(serial_id)))
         end
         setmetatable(args, { __serial_class = classes[serial_id] })
         visited[PENDING_CLASS_OBJS][args] = true
         visited[#visited + 1] = args
         return args, nextindex
      else
         error("Could not deserialize type byte " .. t .. ".")
      end
   end

   local function serialize(...)
      local visited = {[NEXT] = 1, [CTORSTACK] = {}}
      local accum = {}
      for i = 1, select("#", ...) do
         local x = select(i, ...)
         types[type(x)](x, visited, accum)
      end
      return concat(accum)
   end

   local function make_file_writer(file)
      return setmetatable({}, {
            __newindex = function(_, _, v)
               file:write(v)
            end
      })
   end

   local function serialize_to_file(path, mode, ...)
      local file, err = io.open(path, mode)
      assert(file, err)
      local visited = {[NEXT] = 1, [CTORSTACK] = {}}
      local accum = make_file_writer(file)
      for i = 1, select("#", ...) do
         local x = select(i, ...)
         types[type(x)](x, visited, accum)
      end
      -- flush the writer
      file:flush()
      file:close()
   end

   local function writeFile(path, ...)
      return serialize_to_file(path, "wb", ...)
   end

   local function appendFile(path, ...)
      return serialize_to_file(path, "ab", ...)
   end

   local function deserialize_stage2(visited)
      for obj, _ in pairs(visited[PENDING_CLASS_OBJS]) do
         local mt = getmetatable(obj)
         local klass = mt.__serial_class
         if type(klass) ~= "table" then
            error("Missing serial class")
         end
         local ret = klass.deserialize(unpack(obj))

         if type(ret) ~= "table" then
            error("deserialize() callback for class " .. klass.__name .. " did not return table")
         end

         setmetatable(obj, nil)
         table.replace_with(obj, ret)
         setmetatable(obj, klass)
      end
   end

   local function deserialize(str, index)
      assert(type(str) == "string", "Expected string to deserialize.")
      local vals = {}
      index = index or 1
      local visited = {[PENDING_CLASS_OBJS] = {}}
      local len = 0
      local val
      while true do
         local nextindex
         val, nextindex = deserialize_value(str, index, visited)
         if nextindex > index then
            len = len + 1
            vals[len] = val
            index = nextindex
         else
            break
         end
      end
      deserialize_stage2(visited)
      return vals, len
   end

   local function deserializeN(str, n, index)
      assert(type(str) == "string", "Expected string to deserialize.")
      n = n or 1
      assert(type(n) == "number", "Expected a number for parameter n.")
      assert(n > 0 and floor(n) == n, "N must be a poitive integer.")
      local vals = {}
      index = index or 1
      local visited = {[PENDING_CLASS_OBJS] = {}}
      local len = 0
      local val
      while len < n do
         local nextindex
         val, nextindex = deserialize_value(str, index, visited)
         if nextindex > index then
            len = len + 1
            vals[len] = val
            index = nextindex
         else
            break
         end
      end
      vals[len + 1] = index
      deserialize_stage2(visited)
      return unpack(vals, 1, n + 1)
   end

   local function readFile(path)
      local file, err = io.open(path, "rb")
      assert(file, err)
      local str = file:read("*all")
      file:close()
      return deserialize(str)
   end

    local function hasRegistry(id)
        return serial_ids[id] ~= nil
    end

    -- Used to serialize classes withh custom serializers and deserializers.
    -- If no _serialize or _deserialize (or no _template) value is found in the
    -- metatable, then the metatable is registered as a resources.
    local function register(metatable, name, serialize, deserialize)
        local id = metatable
        if type(metatable) == "table" then
            id = metatable.__id or id
            name = name or metatable.name
            serialize = serialize or metatable._serialize
            deserialize = deserialize or metatable._deserialize
        elseif type(metatable) == "string" then
            name = name or metatable
        end
        type_check(name, "string", "name")
        type_check(serialize, "function", "serialize")
        type_check(deserialize, "function", "deserialize")
        assert((not serial_ids[id]), "Metatable already registered.")
        assert((not mts[name]), ("Name %q already registered."):format(name))
        mts[name] = id
        serial_ids[id] = name
        serializers[name] = serialize
        deserializers[name] = deserialize
        return metatable
    end

   local function hasClass(klass)
      return classes[klass.__serial_id]
   end

   local function registerClass(klass)
      if not klass.__class or klass.__class ~= klass then
         error("Cannot register class " .. tostring(klass) .. " for serialization: Is not a class")
      end

      local serial_id = klass.__serial_id

      if RESERVED_IDS[serial_id] then
         error("Cannot register class " .. klass.__name .. " for serialization: __serial_id '" .. serial_id .. "' is reserved")
      end

      if type(serial_id) ~= "string" then
         error("Cannot register class " .. klass.__name .. " for serialization: Does not declare __serial_id string property")
      end

      if serial_ids[klass] then
         print("Warning: redefining serial ID " .. serial_id .. " for class " .. klass.__name)
      end

      classes[serial_id] = klass
      serial_ids[klass] = serial_id
   end

   local function clearRegistry()
      mts = {}
      serializers = {}
      deserializers = {}
      classes = {}
      serial_ids = {}
   end

   return {
      VERSION = "0.0-8ON",
      -- aliases
      s = serialize,
      d = deserialize,
      dn = deserializeN,
      r = readFile,
      w = writeFile,
      a = appendFile,

      serialize = serialize,
      deserialize = deserialize,
      deserializeN = deserializeN,
      readFile = readFile,
      writeFile = writeFile,
      hasRegistry = hasRegistry,
      register = register,
      appendFile = appendFile,
      hasClass = hasClass,
      registerClass = registerClass,
      clearRegistry = clearRegistry,

      newbinser = newbinser
   }
end

return newbinser()
