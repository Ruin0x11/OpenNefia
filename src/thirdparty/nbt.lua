--[[---------------------------------------------------------------------------
-- Copyright (c) 2040 Dark Energy Processor
--
-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
--
-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgment in the product documentation would be
--    appreciated but is not required.
-- 2. Altered source versions must be plainly marked as such, and must not
--    be misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source
--    distribution.
--]]---------------------------------------------------------------------------

-- Lua 5.1 or later is required
assert(_VERSION >= "Lua 5.1", "At least Lua 5.1 is required for this library")

local nbt = {
	_VERSION = "1.0.1",
	_DESCRIPTION = "Named Binary Tag library for Lua",
	_URL = "https://github.com/MikuAuahDark/lua-nbt",
	_LICENSE = "zLib"
}

-- Tag constants
local TAG_END = 0 nbt.TAG_END = 0
local TAG_BYTE = 1 nbt.TAG_BYTE = 1
local TAG_SHORT = 2 nbt.TAG_SHORT = 2
local TAG_INT = 3 nbt.TAG_INT = 3
local TAG_LONG = 4 nbt.TAG_LONG = 4
local TAG_FLOAT = 5 nbt.TAG_FLOAT = 5
local TAG_DOUBLE = 6 nbt.TAG_DOUBLE = 6
local TAG_BYTE_ARRAY = 7 nbt.TAG_BYTE_ARRAY = 7
local TAG_STRING = 8 nbt.TAG_STRING = 8
local TAG_LIST = 9 nbt.TAG_LIST = 9
local TAG_COMPOUND = 10 nbt.TAG_COMPOUND = 10
local TAG_INT_ARRAY = 11 nbt.TAG_INT_ARRAY = 11
local TAG_LONG_ARRAY = 12 nbt.TAG_LONG_ARRAY = 12

-- Internal uses
local isLuaJIT = pcall(require, "jit")
local isLua53 = _VERSION >= "Lua 5.3" -- Should work for now

-- Internal functions
local getLongInt, longIntTostring, toInteger, encodeLongInt, decodeLongInt
local encodeShort, encodeInt, decodeShort, decodeInt
local encodeFloat, encodeDouble, decodeFloat, decodeDouble
if isLuaJIT then
	-- Use LuaJIT boxed 64-bit int
	local ffi = require("ffi")
	local i64 = ffi.new("union {int64_t a; uint8_t b[8]; double c;}")
	local i32f = ffi.new("union {float a; uint8_t b[4];}")
	local zeroLL = loadstring("return 0LL")()

	function getLongInt(self)
		return self._value + zeroLL
	end

	function longIntTostring(v)
		return tostring(v + zeroLL):sub(1, -2) -- remove additional "L"
	end

	function toInteger(v)
		return v < 0 and math.ceil(v) or math.floor(v)
	end

	if ffi.abi("be") then
		function encodeLongInt(v)
			i64.a = v
			return ffi.string(i64.b, 8)
		end

		function decodeLongInt(str)
			ffi.copy(i64.b, str, 8)
			return i64.a
		end

		function encodeDouble(v)
			i64.c = v
			return ffi.string(i64.b, 8)
		end

		function decodeDouble(str)
			ffi.copy(i64.b, str, 8)
			return i64.c
		end

		function encodeFloat(v)
			i32f.a = v
			return ffi.string(i32f.b, 4)
		end

		function decodeFloat(str)
			ffi.copy(i32f.b, str, 4)
			return i32f.a
		end
	else
		function encodeLongInt(v)
			i64.a = v
			return string.char(
				i64.b[7],
				i64.b[6],
				i64.b[5],
				i64.b[4],
				i64.b[3],
				i64.b[2],
				i64.b[1],
				i64.b[0]
			)
		end

		function decodeLongInt(str)
			local a, b, c, d, e, f, g, h = str:byte(1, 8)
			i64.b[0], i64.b[1], i64.b[2], i64.b[3] = h, g, f, e
			i64.b[4], i64.b[5], i64.b[6], i64.b[7] = d, c, b, a
			return i64.a
		end

		function encodeDouble(v)
			i64.c = v
			return string.char(
				i64.b[7],
				i64.b[6],
				i64.b[5],
				i64.b[4],
				i64.b[3],
				i64.b[2],
				i64.b[1],
				i64.b[0]
			)
		end

		function decodeDouble(str)
			local a, b, c, d, e, f, g, h = str:byte(1, 8)
			i64.b[0], i64.b[1], i64.b[2], i64.b[3] = h, g, f, e
			i64.b[4], i64.b[5], i64.b[6], i64.b[7] = d, c, b, a
			return i64.c
		end

		function encodeFloat(v)
			i32f.a = v
			return string.char(
				i32f.b[3],
				i32f.b[2],
				i32f.b[1],
				i32f.b[0]
			)
		end

		function decodeFloat(str)
			local a, b, c, d = str:byte(1, 4)
			i32f.b[0], i32f.b[1], i32f.b[2], i32f.b[3] = d, c, b, a
			return i32f.a
		end
	end
elseif isLua53 then
	-- Use Lua 5.3 integer
	function toInteger(v)
		return math.tointeger(v < 0 and math.ceil(v) or math.floor(v))
	end
	function getLongInt(self)
		return toInteger(self._value)
	end

	function longIntTostring(v)
		return string.format("%dL", v)
	end

	function encodeLongInt(v)
		return string.pack(">i8", v)
	end

	function decodeLongInt(str)
		return string.unpack(">i8", str)
	end

	function encodeDouble(v)
		return string.pack(">d", v)
	end

	function decodeDouble(str)
		return string.unpack(">d", str)
	end

	function encodeFloat(v)
		return string.pack(">f", v)
	end

	function decodeFloat(str)
		return string.unpack(">f", str)
	end
else
	local log2 = math.log(2)
	local frexp = not(isLuaJIT) and math.frexp or function(x)
		-- Stolen't from cpml/utils
		if x == 0 then return 0, 0 end
		local e = math.floor(math.log(math.abs(x)) / log2 + 1)
		return x / 2 ^ e, e
	end

	-- Default for Lua 5.1/5.2
	function getLongInt(self)
		return self._value < 0 and math.ceil(self._value) or math.floor(self._value)
	end

	function longIntTostring(v)
		-- May imprecise but we have no choice
		return string.format("%.0fL", v)
	end

	function toInteger(v)
		return v < 0 and math.ceil(v) or math.floor(v)
	end

	function encodeLongInt(v)
		-- This was shamelessly stolen from lua-MessagePack
		return string.char(
			v < 0 and 255 or 0, -- only 53 bits from double
			math.floor(v / 0x1000000000000) % 0x100,
			math.floor(v / 0x10000000000) % 0x100,
			math.floor(v / 0x100000000) % 0x100,
			math.floor(v / 0x1000000) % 0x100,
			math.floor(v / 0x10000) % 0x100,
			math.floor(v / 0x100) % 0x100,
			v % 0x100
		)
	end

	function decodeLongInt(str)
		-- This was shamelessly stolen from lua-MessagePack
		local a, b, c, d, e, f, g, h = str:byte(1, 8)
		if a > 128 then
			a, b, c, d = a - 255, b - 255, c - 255, d - 255
			e, f, g, h = e - 255, f - 255, g - 255, h - 255
		end

		return ((((((a * 256 + b) * 256 + c) * 256 + d) * 256 + e) * 256 + f) * 256 + g) * 256 + h
	end

	function encodeDouble(v)
		-- This was shamelessly stolen from lua-MessagePack
		local sign = v < 0 and 128 or 0
		local mant, expo = frexp(v)

		if mant ~= mant then
			-- NaN
			return "\255\248\0\0\0\0\0\0"
		elseif mant == math.huge or expo > 1024 then
			if sign == 0 then
				-- +inf
				return "\127\240\0\0\0\0\0\0"
			else
				-- -inf
				return "\255\240\0\0\0\0\0\0"
			end
		elseif (mant == 0 and expo == 0) or expo < -1022 then
			-- zero
			return string.char(sign).."\0\0\0\0\0\0\0"
		else
			expo = expo + 1022
			mant = math.floor((math.abs(mant) * 2.0 - 1.0) * 4503599627370496)
			return string.char(
				sign + math.floor(expo / 16),
				(expo % 16) * 16 + math.floor(mant / 0x1000000000000),
				math.floor(mant / 0x10000000000) % 256,
				math.floor(mant / 4294967296) % 256,
				math.floor(mant / 16777216) % 256,
				math.floor(mant / 65536) % 256,
				math.floor(mant / 256) % 256,
				mant % 256
			)
		end
	end

	function decodeDouble(str)
		-- This was shamelessly stolen from lua-MessagePack
		local a, b, c, d, e, f, g, h = str:byte(1, 8)
		local sign = a > 127 and -1 or 1
		local expo = (a % 128) * 16 + math.floor(b / 16)
		local mant = ((((((b % 16) * 256 + c) * 256 + d) * 256 + e) * 256 + f) * 256 + g) * 256 + h
		if mant == 0 and expo == 0 then
			return sign * 0.0
		elseif expo == 2047 then
			if mant == 0 then
				return sign * math.huge
			else
				return 0.0/0.0
			end
		else
			return sign * ((1.0 + mant / 4503599627370496.0) * 2 ^ (expo - 1023))
		end
	end

	function encodeFloat(v)
		-- This was shamelessly stolen from lua-MessagePack
		local sign = v < 0 and 128 or 0
		local mant, expo = frexp(v)

		if mant ~= mant then
			-- NaN
			return "\255\136\0\0"
		elseif mant == math.huge or expo > 128 then
			if sign then
				-- +inf
				return "\127\128\0\0"
			else
				-- -inf
				return "\255\128\0\0"
			end
		elseif (mant == 0 and expo == 0) or expo < -126 then
			-- zero
			return string.byte(sign).."\0\0\0"
		else
			expo = expo + 126
			mant = math.floor((math.abs(mant) * 2.0 - 1.0) * 8388608)
			return string.char(
				sign + math.floor(expo / 2),
				(expo % 2) * 128 + math.floor(mant / 65536),
				math.floor(mant / 256) % 256,
				mant % 256
			)
		end
	end

	function decodeFloat(str)
		-- This was shamelessly stolen from lua-MessagePack
		local a, b, c, d = str:byte(1, 4)
		local sign = a > 127 and -1 or 1
		local expo = (a % 128) * 2 + math.floor(b / 128)
		local mant = ((b % 128) * 256 + c) * 256 + d
		if mant == 0 and expo == 0 then
			return sign * 0.0
		elseif expo == 255 then
			if mant == 0 then
				return sign * math.huge
			else
				return 0.0/0.0
			end
		else
			return sign * ((1.0 + mant / 8388608) * 2 ^ (expo - 127))
		end
	end
end

local function isCorrectTypeID(typeID)
	return
		type(typeID) == "number" and (
		typeID == TAG_BYTE or
		typeID == TAG_SHORT or
		typeID == TAG_INT or
		typeID == TAG_LONG or
		typeID == TAG_FLOAT or
		typeID == TAG_DOUBLE or
		typeID == TAG_BYTE_ARRAY or
		typeID == TAG_STRING or
		typeID == TAG_LIST or
		typeID == TAG_COMPOUND or
		typeID == TAG_INT_ARRAY or
		typeID == TAG_LONG_ARRAY)
end

if isLua53 then
	function encodeShort(v)
		return string.pack(">i2", v)
	end

	function decodeShort(str)
		return string.unpack(">i2", str:sub(1, 2))
	end

	function encodeInt(v)
		return string.pack(">i4", v)
	end

	function decodeInt(str)
		return string.unpack(">i4", str:sub(1, 4))
	end
else
	function encodeShort(v)
		v = v % 65536
		return string.char(math.floor(v / 256), math.floor(v) % 256)
	end

	function decodeShort(str)
		local a, b = str:byte(1, 2)
		return a * 256 + b
	end

	function encodeInt(v)
		v = v % 4294967296
		return string.char(
			math.floor(v / 16777216),
			math.floor(v / 65536) % 256,
			math.floor(v / 256) % 256,
			math.floor(v) % 256
		)
	end

	function decodeInt(str)
		local a, b, c, d = str:byte(1, 4)
		return a * 16777216 + b * 65536 + c * 256 + d
	end
end

local function limitString(v)
	v = v:gsub("%z", "\192\128") -- Java modified UTF-8
	return v:sub(1, math.min(#v, 32767))
end

-- NBT TAG_* class
local TagClass = {
	-- Names, no need to use separate table
	"TAG_Byte",
	"TAG_Short",
	"TAG_Int",
	"TAG_Long",
	"TAG_Float",
	"TAG_Double",
	"TAG_Byte_Array",
	"TAG_String",
	"TAG_List",
	"TAG_Compound",
	"TAG_Int_Array",
	"TAG_Long_Array"
}
TagClass.__index = TagClass

function TagClass.new(type, val, name)
	local t = setmetatable({
		-- No sanity check because this class is used internally
		_value = val,
		_name = name or "",
		_type = assert(tonumber(type), "invalid type id")
	}, TagClass)
	return t
end

-- This actually pretty print and
-- may result in very long string
function TagClass:__tostring(indent, noname)
	indent = indent or 0
	local prefix
	local ind = string.rep("  ", indent)

	if noname then
		prefix = string.format("%s%s(None): ", ind, TagClass[self._type])
	else
		prefix = string.format("%s%s(%q): ", ind, TagClass[self._type], self._name)
	end

	if
		self._type == TAG_BYTE or
		self._type == TAG_SHORT or
		self._type == TAG_INT
	then
		return string.format("%s%d", prefix, self._value)
	elseif
		self._type == TAG_FLOAT or
		self._type == TAG_DOUBLE
	then
		return string.format("%s%.14g", prefix, self._value)
	elseif self._type == TAG_LONG then
		return string.format("%s%s", prefix, longIntTostring(self._value))
	elseif self._type == TAG_STRING then
		return string.format("%s%q", prefix, self._value)
	elseif
		self._type == TAG_LIST or
		self._type == TAG_COMPOUND
	then
		local isList = self._type == TAG_LIST
		local strb = {}
		local j = indent + 1

		for i, v in ipairs(self._value) do
			strb[i] = v:__tostring(j, isList)
		end

		local len = #strb
		return string.format(
			"%s%d entr%s\n%s{\n%s\n%s}", -- uh crazy string formats
			prefix, len,
			len == 1 and "y" or "ies",
			ind,
			table.concat(strb, "\n"),
			ind
		)
	elseif
		self._type == TAG_BYTE_ARRAY or
		self._type == TAG_INT_ARRAY
	then
		-- value is table in this case
		local strb = {}

		for i, v in ipairs(self._value) do
			strb[i] = tostring(v)
		end

		return string.format("%s[%s]", prefix, table.concat(strb, ", "))
	elseif self._type == TAG_LONG_ARRAY then
		-- same as above but have to call longIntTostring
		local strb = {}

		for i, v in ipairs(self._value) do
			strb[i] = longIntTostring(v)
		end

		return string.format("%s[%s]", prefix, table.concat(strb, ", "))
	end
end

function TagClass:getTypeID()
	return self._type
end

function TagClass:getName()
	return self._name
end

function TagClass:getString()
	if
		self._type == TAG_BYTE_ARRAY or
		self._type == TAG_LIST or
		self._type == TAG_COMPOUND or
		self._type == TAG_INT_ARRAY or
		self._type == TAG_LONG_ARRAY
	then
		error("attempt to get string of array value")
	end

	return tostring(self._value)
end

function TagClass:getNumber()
	if
		self._type == TAG_BYTE or
		self._type == TAG_SHORT or
		self._type == TAG_INT or
		self._type == TAG_LONG or
		self._type == TAG_FLOAT or
		self._type == TAG_DOUBLE
	then
		return tonumber(self._value) + 0.0 -- Lua 5.3 to float
	elseif self._type == TAG_STRING then
		-- Try tonumber it
		local num = tonumber(self._value)
		if num then
			return num + 0.0 -- Lua 5.3 to float
		end
	end

	error("attempt to get number of invalid type")
end

function TagClass:getInteger()
	if
		self._type == TAG_BYTE or
		self._type == TAG_SHORT or
		self._type == TAG_INT or
		self._type == TAG_FLOAT or
		self._type == TAG_DOUBLE
	then
		return toInteger(self._value < 0 and math.ceil(self._value) or math.floor(self._value))
	elseif self._type == TAG_LONG then
		return getLongInt(self)
	elseif self._type == TAG_STRING then
		-- Try tonumber first
		local num = tonumber(self._value)
		if num then
			return toInteger(num < 0 and math.ceil(num) or math.floor(num))
		end
	end

	error("attempt to get integer of invalid type")
end

function TagClass:getValue()
	return self._value
end

function TagClass:copy(shallow)
	if self._type == TAG_LIST or self._type == TAG_COMPOUND then
		if shallow then
			-- Only copy top element
			local new = {}

			for k, v in pairs(self._value) do
				new[k] = v
			end

			return TagClass.new(self._type, new, self._name)
		else
			-- Copy recursively
			local new = {}

			for k, v in pairs(self._value) do
				new[k] = v:copy()
			end

			return TagClass.new(self._type, new, self._name)
		end
	elseif
		self._type == TAG_BYTE_ARRAY or
		self._type == TAG_INT_ARRAY or
		self._type == TAG_LONG_ARRAY
	then
		-- Copy elements
		local new = {}

		for i, v in ipairs(self._value) do
			new[i] = v
		end

		return TagClass.new(self._type, new, self._name)
	else
		return TagClass.new(self._type, self._value, self._name)
	end
end

function TagClass:encode(noprefix)
	local name
	if not(noprefix) then
		name = limitString(self._name)
	end

	if self._type == TAG_BYTE then
		if noprefix then
			return string.char(self._value % 256)
		else
			-- May strip UTF-8 encoding
			return "\1"..encodeShort(#name)..name..string.char(self._value % 256)
		end
	elseif self._type == TAG_BYTE_ARRAY then
		local strb = {}

		-- Convert all bytes to string
		for i, v in ipairs(self._value) do
			strb[i] = string.char(v % 256)
		end

		if noprefix then
			return encodeInt(#strb)..table.concat(strb)
		else
			return "\7"..encodeShort(#name)..name..encodeInt(#strb)..table.concat(strb)
		end
	elseif self._type == TAG_SHORT then
		if noprefix then
			return encodeShort(self._value)
		else
			return "\2"..encodeShort(#name)..name..encodeShort(self._value)
		end
	elseif self._type == TAG_INT then
		if noprefix then
			return encodeInt(self._value)
		else
			return "\3"..encodeShort(#name)..name..encodeInt(self._value)
		end
	elseif self._type == TAG_INT_ARRAY then
		local strb = {}

		-- Convert all values to int
		for i, v in ipairs(self._value) do
			strb[i] = encodeInt(v)
		end

		if noprefix then
			return encodeInt(#strb)..table.concat(strb)
		else
			return "\11"..encodeShort(#name)..name..encodeInt(#strb)..table.concat(strb)
		end
	elseif self._type == TAG_LONG then
		if noprefix then
			return encodeLongInt(self._value)
		else
			return "\4"..encodeShort(#name)..name..encodeLongInt(self._value)
		end
	elseif self._type == TAG_LONG_ARRAY then
		local strb = {}

		-- Convert all values to long
		for i, v in ipairs(self._value) do
			strb[i] = encodeLongInt(v)
		end

		if noprefix then
			return encodeInt(#strb)..table.concat(strb)
		else
			return "\12"..encodeShort(#name)..name..encodeInt(#strb)..table.concat(strb)
		end
	elseif self._type == TAG_FLOAT then
		if noprefix then
			return encodeFloat(self._value)
		else
			return "\5"..encodeShort(#name)..name..encodeFloat(self._value)
		end
	elseif self._type == TAG_DOUBLE then
		if noprefix then
			return encodeDouble(self._value)
		else
			return "\6"..encodeShort(#name)..name..encodeDouble(self._value)
		end
	elseif self._type == TAG_STRING then
		local valueTrunc = limitString(self._value)
		if noprefix then
			return encodeShort(#valueTrunc)..valueTrunc
		else
			return "\8"..encodeShort(#name)..name..encodeShort(#valueTrunc)..valueTrunc
		end
	elseif self._type == TAG_LIST then
		-- Special case if length is 0
		if #self._value == 0 then
			if noprefix then
				return "\0\0\0\0\0"
			else
				return "\9"..encodeShort(#name)..name.."\0\0\0\0\0"
			end
		else
			local typeID = 0
			local strb = {}

			for i, v in ipairs(self._value) do
				local id = v:getTypeID()

				if typeID == 0 then
					typeID = id
				elseif typeID ~= id then
					error("TAG_List type inconsistent (old "..typeID.." new "..id..")")
				end

				strb[i] = v:encode(true)
			end

			if noprefix then
				return string.char(typeID)..encodeInt(#strb)..table.concat(strb)
			else
				return "\9"..encodeShort(#name)..name..string.char(typeID)..encodeInt(#strb)..table.concat(strb)
			end
		end
	elseif self._type == TAG_COMPOUND then
		local strb = {}

		for i, v in ipairs(self._value) do
			strb[i] = v:encode()
		end

		if noprefix then
			return table.concat(strb).."\0"
		else
			return "\10"..encodeShort(#name)..name..table.concat(strb).."\0"
		end
	else
		return ""
	end
end

-- Public NBT functions

--- Create new `TAG_Byte` object.
-- @tparam number v Byte value
-- @tparam[opt] string name Tag name
-- @return Tag class with `TAG_Byte` type.
-- @warning Value will be converted integer and
-- clamped to -128...127 if outside range
function nbt.newByte(v, name)
	v = assert(tonumber(v), "invalid number passed")
	return TagClass.new(TAG_BYTE, toInteger(math.min(math.max(v, -128), 127)), name)
end

--- Create new `TAG_Short` object.
-- @tparam number v Short value
-- @tparam[opt] string name Tag name
-- @return Tag class with `TAG_Short` type.
-- @warning Value will be converted integer and
-- clamped to -32768...32767 if outside range
function nbt.newShort(v, name)
	v = assert(tonumber(v), "invalid number passed")
	return TagClass.new(TAG_SHORT, toInteger(math.min(math.max(v, -32768), 32767)), name)
end

--- Create new `TAG_Int` object.
-- @tparam number v Int value
-- @tparam[opt] string name Tag name
-- @return Tag class with `TAG_Int` type.
-- @warning Value will be converted integer and
-- clamped to -2147483648...2147483647 if outside range
function nbt.newInt(v, name)
	v = assert(tonumber(v), "invalid number passed")
	return TagClass.new(TAG_INT, toInteger(math.min(math.max(v, -2147483648), 2147483647)), name)
end

if isLuaJIT then
	-- As much as I want to avoid FFI
	local ffi = require("ffi")

	function nbt.newLong(v, name)
		v = ffi.cast("int64_t", v)
		return TagClass.new(TAG_LONG, v, name)
	end

	function nbt.newLongArray(value, name)
		local list = {}

		for i, v in ipairs(value) do
			if getmetatable(v) == TagClass then
				v = v:getInteger()
			elseif type(v) ~= "number" then
				v = tonumber(v)
			end

			if v == nil then
				error("invalid value at #"..i)
			else
				v = ffi.cast("int64_t", v)
			end

			list[i] = v
		end

		return TagClass.new(TAG_LONG_ARRAY, list, name)
	end
else
	function nbt.newLong(v, name)
		v = assert(tonumber(v), "invalid number passed")
		return TagClass.new(TAG_INT, toInteger(math.min(math.max(v, -9223372036854775808), 9223372036854775807)), name)
	end

	function nbt.newLongArray(value, name)
		local list = {}

		for i, v in ipairs(value) do
			if getmetatable(v) == TagClass then
				v = v:getInteger()
			elseif type(v) ~= "number" then
				v = tonumber(v)
			end

			if v == nil then
				error("invalid value at #"..i)
			else
				v = toInteger(math.min(math.max(v, -9223372036854775808), 9223372036854775807))
			end

			list[i] = v
		end

		return TagClass.new(TAG_LONG_ARRAY, list, name)
	end
end

--- Create new `TAG_Float` object.
-- @tparam number v Float value
-- @tparam[opt] string name Tag name
-- @return Tag class with `TAG_Float` type.
function nbt.newFloat(v, name)
	return TagClass.new(TAG_FLOAT, v, name)
end

--- Create new `TAG_Double` object.
-- @tparam number v Double float value
-- @tparam[opt] string name Tag name
-- @return Tag class with `TAG_Double` type.
function nbt.newDouble(v, name)
	return TagClass.new(TAG_DOUBLE, v, name)
end

--- Create new `TAG_String` object.
-- @tparam string v String value
-- @tparam[opt] string name Tag name
-- @return Tag class with `TAG_String` type.
function nbt.newString(v, name)
	return TagClass.new(TAG_STRING, tostring(v), name)
end

--- Create new `TAG_Compound` object.
-- @tparam table value List of key-value pairs in table
-- @tparam[opt] string name description
-- @return Tag class with `TAG_List` type.
-- @warning If `TAG_*` class object is passed, this function will take
-- the ownership of that object and modify it, so make sure to clone the
-- object if needed.
function nbt.newCompound(value, name)
	local compound = {}

	for k, v in pairs(value) do
		if type(k) ~= "string" then
			error(string.format("invalid key %q", k))
		end

		if getmetatable(v) == TagClass then
			v._name = k
			compound[#compound + 1] = v
			compound[k] = v
		else
			local datatype = type(v)
			-- We have to do some guessing here
			-- "cdata" must also be checked because LuaJIT boxed 64-bit int
			if datatype == "number" or datatype == "cdata" then
				-- if value is integer, do integer guessing
				if v % 1 == 0 then
					local y

					if v >= -128 and v <= 127 then
						y = nbt.newByte(tonumber(v), k)
					elseif v >= -32768 and v <= 32767 then
						y = nbt.newShort(tonumber(v), k)
					elseif v >= -2147483648 and v <= 2147483647 then
						y = nbt.newInt(tonumber(v), k)
					else
						y = nbt.newLong(v, k)
					end

					y._name = k
					compound[#compound + 1] = y
					compound[k] = y
				else
					-- assume double, default Lua
					local y = nbt.newDouble(v, k)
					compound[#compound + 1] = y
					compound[k] = y
				end
			elseif datatype == "string" then
				local y = nbt.newString(v, k)
				y._name = k
				compound[#compound + 1] = y
				compound[k] = y
			else
				-- Should've implement type checking but
				-- in Lua it's too complex and may slow
				error(string.format("invalid value for key %q", k))
			end
		end
	end

	return TagClass.new(TAG_COMPOUND, compound, name)
end

--- Create new `TAG_List` object.
-- @tparam number typeID Valid NBT type ID (`nbt.TAG_*` constants) excluding `TAG_END`
-- @tparam table value List of values in table
-- @tparam[opt] string name description
-- @return Tag class with `TAG_List` type.
-- @warning If `TAG_*` class object is passed, this function will take
-- the ownership of that object, so make sure to clone the object if needed.
function nbt.newList(typeID, value, name)
	assert(isCorrectTypeID(typeID), "invalid type ID passed")

	local constructorFunction
	local list = {}

	if typeID == TAG_BYTE then
		constructorFunction = nbt.newByte
	elseif typeID == TAG_SHORT then
		constructorFunction = nbt.newShort
	elseif typeID == TAG_INT then
		constructorFunction = nbt.newInt
	elseif typeID == TAG_LONG then
		constructorFunction = nbt.newLong
	elseif typeID == TAG_STRING then
		constructorFunction = nbt.newString
	end

	for i, v in ipairs(value) do
		if getmetatable(v) == TagClass then
			if v:getTypeID() == typeID then
				list[i] = v
			else
				error("type ID mismatch at table index #"..i)
			end
		elseif constructorFunction == nil then
			error("cannot type deduce value at index #"..i)
		end

		list[i] = constructorFunction(v)
	end

	return TagClass.new(TAG_LIST, list, name)
end

--- Create new `TAG_Byte_Array` object.
-- @tparam table value List of values in table
-- @tparam[opt] string name description
-- @return Tag class with `TAG_Byte_Array` type.
function nbt.newByteArray(value, name)
	local list = {}

	for i, v in ipairs(value) do
		if getmetatable(v) == TagClass then
			v = v:getInteger()
		elseif type(v) ~= "number" then
			v = tonumber(v)
		end

		if v == nil then
			error("invalid value at #"..i)
		else
			v = toInteger(math.min(math.max(v, -128), 127))
		end

		list[i] = v
	end

	return TagClass.new(TAG_BYTE_ARRAY, list, name)
end

--- Create new `TAG_Int_Array` object.
-- @tparam table value List of values in table
-- @tparam[opt] string name description
-- @return Tag class with `TAG_Int_Array` type.
function nbt.newIntArray(value, name)
	local list = {}

	for i, v in ipairs(value) do
		if getmetatable(v) == TagClass then
			v = v:getInteger()
		elseif type(v) ~= "number" then
			v = tonumber(v)
		end

		if v == nil then
			error("invalid value at #"..i)
		else
			v = toInteger(math.min(math.max(v, -2147483648), 2147483647))
		end

		list[i] = v
	end

	return TagClass.new(TAG_INT_ARRAY, list, name)
end

-- Internal use
local IncrementalReader = {}
IncrementalReader.__index = IncrementalReader

function IncrementalReader.new(input)
	local datatype = type(input)
	if datatype == "string" then
		return setmetatable({string = input, pos = 0}, IncrementalReader)
	elseif datatype == "function" then
		return setmetatable({buffer = input, string = "", pos = 0}, IncrementalReader)
	end
end

function IncrementalReader:read(n)
	if n <= 0 then return "" end

	if self.string and #self.string < n then
		if self.buffer then
			local minsize = n - #self.string
			local str, msg = self.buffer(minsize)

			if not(str) then error(msg)
			elseif #str == 0 then error("returned buffer is empty string")
			elseif #str < minsize then error("returned buffer is less than minsize") end

			self.string = self.string..str
		else
			error("unexpected eof at pos "..self.pos)
		end
	end

	local v = self.string:sub(1, n)
	self.string = self.string:sub(n + 1)
	self.pos = self.pos + n
	return v
end

function IncrementalReader:getPos()
	return self.pos
end

local function deserializeNBTFull(reader, typeID, readName, createTag)
	if not(typeID) then
		typeID = deserializeNBTFull(reader, TAG_BYTE)
	end

	-- This must be done early
	if typeID == TAG_END then
		return nil, nil, TAG_END
	end

	if readName == true then
		local namelen = decodeShort(reader:read(2))
		readName = (reader:read(namelen):gsub("\192\128", "\0"))
	else
		readName = nil
	end

	if typeID == TAG_BYTE then
		local b = reader:read(1):byte()
		if b > 127 then
			b = b - 256
		end
		return b, readName, TAG_BYTE
	elseif typeID == TAG_SHORT then
		return decodeShort(reader:read(2)), readName, TAG_SHORT
	elseif typeID == TAG_INT then
		return decodeInt(reader:read(4)), readName, TAG_INT
	elseif typeID == TAG_LONG then
		return decodeLongInt(reader:read(8)), readName, TAG_LONG
	elseif typeID == TAG_FLOAT then
		return decodeFloat(reader:read(4)), readName, TAG_FLOAT
	elseif typeID == TAG_DOUBLE then
		return decodeDouble(reader:read(8)), readName, TAG_DOUBLE
	elseif typeID == TAG_BYTE_ARRAY then
		local len = decodeInt(reader:read(4))
		local ret = {}

		for i = 1, len do
			ret[i] = deserializeNBTFull(reader, TAG_BYTE)
		end

		return ret, readName, TAG_BYTE_ARRAY
	elseif typeID == TAG_STRING then
		local len = decodeShort(reader:read(2))
		return (reader:read(len):gsub("\192\128", "\0")), readName, TAG_STRING
	elseif typeID == TAG_LIST then
		local targetTypeID = deserializeNBTFull(reader, TAG_BYTE)
		local len = decodeInt(reader:read(4))
		local ret = {}

		if createTag then
			for i = 1, len do
				ret[i] = TagClass.new(targetTypeID, deserializeNBTFull(reader, targetTypeID, false, true))
			end
		else
			for i = 1, len do
				ret[i] = deserializeNBTFull(reader, targetTypeID)
			end
		end

		return ret, readName, TAG_LIST
	elseif typeID == TAG_COMPOUND then
		local ret = {}

		while true do
			local value, name, targetTypeID = deserializeNBTFull(reader, nil, true, createTag)
			if targetTypeID == TAG_END then
				break
			end

			if createTag then
				local x = TagClass.new(targetTypeID, value, name)
				ret[name] = x
				ret[#ret + 1] = x
			else
				ret[name] = value
				ret[#ret + 1] = value
			end
		end

		return ret, readName, TAG_COMPOUND
	elseif typeID == TAG_INT_ARRAY then
		local len = decodeInt(reader:read(4))
		local ret = {}

		for i = 1, len do
			ret[i] = deserializeNBTFull(reader, TAG_INT)
		end

		return ret, readName, TAG_INT_ARRAY
	elseif typeID == TAG_LONG_ARRAY then
		local len = decodeInt(reader:read(4))
		local ret = {}

		for i = 1, len do
			ret[i] = deserializeNBTFull(reader, TAG_LONG)
		end

		return ret, readName, TAG_LONG_ARRAY
	else
		error("unknown tag ID "..typeID.." at "..reader:getPos())
	end
end

--- Decode NBT data.
-- This can either decode into Tag class or plain Lua table.
-- @tparam string|function input uncompressed NBT input data or function
-- which returns uncompressed NBT data
-- @tparam string preservemode "tag" (default) returns full Tag class
-- or "plain" returns only plain Lua table
function nbt.decode(input, preservemode)
	if type(input) ~= "string" then
		error("bad argument #1 to `decode` (string expected)")
	end

	preservemode = preservemode or "tag"
	local preservetag

	-- Check data output mode
	if preservemode == "tag" then
		preservetag = true
	elseif preservemode == "plain" then
		preservetag = false
	else
		error("bad argument #2 to 'decode' (invalid 'preservemode')")
	end

	local reader = IncrementalReader.new(input)
	local result, name, typeID = deserializeNBTFull(reader, nil, true, preservetag)

	if preservetag then
		result = TagClass.new(typeID, result, name)
		return result
	else
		return result, name
	end

end

return nbt
