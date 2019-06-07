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
