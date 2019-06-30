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

local function escape_for_gsub(s)
   return string.gsub(s, "([^%w])", "%%%1")
end

function string.has_prefix(s, prefix)
   return string.find(s, "^" .. escape_for_gsub(prefix))
end

function string.has_suffix(s, suffix)
   return string.find(s, escape_for_gsub(suffix) .. "$")
end

function string.strip_prefix(s, prefix)
   return string.gsub(s, "^" .. escape_for_gsub(prefix), "")
end

function string.strip_suffix(s, suffix)
   return string.gsub(s, escape_for_gsub(suffix) .. "$", "")
end

function string.split(str, sep)
   sep = sep or ","
   local fields = {}
   local pattern = string.format("([^%s]+)", sep)
   string.gsub(str, pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function string.split_at_pos(str, pos)
   local a = string.sub(str, 0, pos)
   local b = string.sub(str, pos+1)
   return a, b
end

--- Version of tostring that bypasses metatables.
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
