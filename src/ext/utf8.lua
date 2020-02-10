--- @module utf8

if utf8 == nil then
   local ok
   ok, utf8 = pcall(require, "utf8")
   if not ok or (love.getVersion() == "lovemock" and (utf8 == nil or utf8.codes == nil)) then
      -- require the luarocks version (starwing/utf8)
      local ok, result = pcall(require, "lua-utf8")
      if not ok then
         error("Please install luautf8 from luarocks.")
      end
      utf8 = result
      package.loaded["utf8"] = result
   end
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

if utf8.sub == nil then
   --- Analogous to string.sub, but operates on UTF-8 codepoints.
   -- @see string.sub
   -- @tparam string t
   -- @tparam uint i
   -- @tparam uint j
   -- @treturn string
   function utf8.sub(t, i, j)
      local len = utf8.len(t)
      i = i or 0
      j = j or len

      local start = utf8.offset(t, i) or 0
      local finish = (utf8.offset(t, j + 1) or (#t + 1)) - 1

      return string.sub(t, start, finish)
   end
end

-- Returns true if cp is a fullwidth UTF-8 codepoint.
--
-- NOTE: This function isn't completely accurate. It ought to use the
-- UCD East Asian Width table instead.
-- (https://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt)
--
-- @tparam uint cp utf8 codepoint
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
---
-- @tparam string t
-- @treturn uint
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
---
-- @tparam string t
-- @tparam uint i
-- @tparam uint j
-- @treturn string
-- @see string.sub
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

local function iter(state, prev_index)
   if prev_index == -1 then
      return nil
   end
   local next_index = state.iter(state.inner_state, state.inner_index)
   if next_index == nil then
      return -1, string.sub(state.str, prev_index)
   end
   state.inner_index = next_index
   return next_index, string.sub(state.str, prev_index, next_index-1)
end

--- Iterates the characters of a string as UTF-8 substrings.
---
--- @tparam string str
--- @treturn iterator(string)
function utf8.chars(str)
   local inner_iter, inner_state, inner_first = utf8.codes(str)
   return iter, {str=str, iter=inner_iter,inner_state=inner_state,inner_index=inner_first+1}, inner_first+1
end

local function is_first_byte_of_utf8(byte)
   return (byte >= 0 and byte <= 0x7F)
      or (byte >= 0xC2 and byte <= 0xF4)
end

--- Gets the byte pos in str at delta codepoints over. Assumes str is
--- valid Unicode.
---
-- @tparam string str
-- @tparam uint pos byte position
-- @tparam int delta can be negative
-- @treturn[opt] uint
function utf8.find_next_pos(str, pos, delta)
   if delta == 0 then
      return pos
   end
   local old = pos

   local d = math.sign(delta)

   local b = string.byte(str, pos)

   local remain = delta + d

   while b ~= nil do
      if is_first_byte_of_utf8(b) then
         remain = remain - d
         if remain == 0 then
            break
         end
      end
      pos = pos + d
      b = string.byte(str, pos)
   end

   return pos
end

--- Gets the position of the UTF-8 codepoint in `str` at byte position
--- `byte`.
---
--- @tparam string str
--- @tparam uint byte
--- @treturn[opt] uint
function utf8.codepoint_pos(str, byte)
   local cp = 1
   for p, _ in utf8.codes(str) do
      if p >= byte then
         return cp
      end
      cp = cp + 1
   end
   return nil
end
