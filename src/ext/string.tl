--- @module string

function string.nonempty(s: string): boolean
   return type(s) == "string" and s ~= ""
end

function string.lines(s: string): function():string
   if string.sub(s, -1) ~= "\n" then s = s .. "\n" end
   return string.gmatch(s, "(.-)\n")
end

   function string.chars(s: string): function():string
   return string.gmatch(s, ".")
end

function string.escape_for_gsub(s: string): string, number
   return string.gsub(s, "([^%w])", "%%%1")
end

function string.has_prefix(s: string, prefix: string): boolean
   return not not string.find(s, "^" .. string.escape_for_gsub(prefix))
end

function string.has_suffix(s: string, suffix: string): boolean
   return not not string.find(s, string.escape_for_gsub(suffix) .. "$")
end

function string.strip_prefix(s: string, prefix: string): string, number
   return string.gsub(s, "^" .. string.escape_for_gsub(prefix), "")
end

function string.strip_suffix(s: string, suffix: string): string, number
   return string.gsub(s, string.escape_for_gsub(suffix) .. "$", "")
end

function string.strip_whitespace(s: string): string
   local from = s:find"^%s*()"
   return from > s:len() and "" or s:match(".*%S", from)
end

--- Splits a string `str` on separator `sep`.
---
--- @tparam string str
--- @tparam[opt] string sep defaults to "\n"
--- @treturn {string}
function string.split(str: string, sep: string): {string}
   sep = sep or "\n"
   local ret: {string} = {}
   local n=1
   for w in str:gmatch("([^"..sep.."]*)") do
      ret[n] = ret[n] or w
      if w=="" then
         n = n + 1
      end
   end
   return ret
end

function string.split_at_pos(str: string, pos: number): string, string
   local a = string.sub(str, 0, pos)
   local b = string.sub(str, pos+1)
   return a, b
end

--- Version of tostring that bypasses metatables.
---
--- @tparam any tbl
--- @treturn string
function string.tostring_raw(tbl: table): string
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
function string.wrap(str: string, limit: number, indent: string, indent1: string): string
   indent = indent or ""
   indent1 = indent1 or indent
   limit = limit or 72
   local here = 1-#indent1
   local function check(sp: string, st: number, word: string, fi: number): string
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
function string.reflow(str: string, limit: number, indent: string, indent1: string): string
   return (str:gsub("%s*\n%s+", "\n")
              :gsub("%s%s+", " ")
              :gsub("[^\n]+",
                    function(line: string): string
                       return string.wrap(line, limit, indent, indent1)
   end))
end
