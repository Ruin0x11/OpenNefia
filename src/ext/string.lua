--- @module string

function string.nonempty(s)
   return type(s) == "string" and s ~= ""
end

function string.lines(s)
   if string.sub(s, -1) ~= "\n" then s = s .. "\n" end
   return string.gmatch(s, "(.-)\n")
end

function string.chars(s)
   return string.gmatch(s, ".")
end

function string.escape_for_gsub(s)
   return string.gsub(s, "([^%w])", "%%%1")
end

function string.has_prefix(s, prefix)
   return string.find(s, "^" .. string.escape_for_gsub(prefix))
end

function string.has_suffix(s, suffix)
   return string.find(s, string.escape_for_gsub(suffix) .. "$")
end

function string.strip_prefix(s, prefix)
   return string.gsub(s, "^" .. string.escape_for_gsub(prefix), "")
end

function string.strip_suffix(s, suffix)
   return string.gsub(s, string.escape_for_gsub(suffix) .. "$", "")
end

function string.strip_whitespace(s)
   local from = s:match"^%s*()"
   return from > #s and "" or s:match(".*%S", from)
end

function string.left_pad(s, length, pad)
   local res = string.rep(pad or ' ', length - #s) .. s
   return res, res ~= s
end

function string.right_pad(s, length, pad)
   local res = s .. string.rep(pad or ' ', length - #s)
   return res, res ~= s
end

--- Splits a string `str` on separator `sep`.
---
--- @tparam string str
--- @tparam[opt] string sep defaults to "\n"
--- @treturn {string}
function string.split(str,sep)
   sep = sep or "\n"
   local ret={}
   local n=1
   for w in str:gmatch("([^"..sep.."]*)") do
      ret[n] = ret[n] or w
      if w=="" then
         n = n + 1
      end
   end
   return ret
end

function string.split_at_pos(str, pos)
   local a = string.sub(str, 0, pos)
   local b = string.sub(str, pos+1)
   return a, b
end

--- Version of tostring that bypasses metatables.
---
--- @tparam any tbl
--- @treturn string
function string.tostring_raw(tbl)
   if type(tbl) ~= "table" then
      return tostring(tbl)
   end

   local mt = getmetatable(tbl)
   setmetatable(tbl, {})
   local s = tostring(tbl)
   setmetatable(tbl, mt)
   return s
end

--- Wraps a string on a character limit.
---
--- From http://lua-users.org/wiki/StringRecipes
---
--- @tparam string str
--- @tparam uint limit Wrap limit in byte positions.
--- @tparam[opt] string indent Indent of wrapped lines.
--- @tparam[opt] string indent1 Indent of the first line.
--- @treturn string
function string.wrap(str, limit, indent, indent1)
   indent = indent or ""
   indent1 = indent1 or indent
   limit = limit or 72
   local here = 1-#indent1
   local function check(sp, st, word, fi)
      if string.find(sp, "\n") then
         here = st - #indent
      end
      if fi - here > limit then
         here = st - #indent
         return "\n"..indent..word
      end
   end
   return indent1..str:gsub("(%s+)()(%S+)()", check)
end

--- Wraps a string with multiple potential blank lines on a character
--- limit into separate paragraphs.
---
--- @tparam string str
--- @tparam uint limit Wrap limit in byte positions.
--- @tparam[opt] string indent Indent of wrapped lines in paragraphs.
--- @tparam[opt] string indent1 Indent of new paragraphs.
--- @treturn string
function string.reflow(str, limit, indent, indent1)
   return (str:gsub("%s*\n%s+", "\n")
              :gsub("%s%s+", " ")
              :gsub("[^\n]+",
                    function(line)
                       return string.wrap(line, limit, indent, indent1)
   end))
end

function string.to_snake_case(s)
   return s:gsub('%f[^%l]%u','_%1')
      :gsub('%f[^%a]%d','_%1')
      :gsub('%f[^%d]%a','_%1')
      :gsub('(%u)(%u%l)','%1_%2')
      :lower()
end
