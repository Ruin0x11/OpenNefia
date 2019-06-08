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

local function escape_for_gsub(text)
   return string.gsub(text, "([^%w])", "%%%1")
end

function string.strip_prefix(s, prefix)
   return string.gsub(s, "^" .. escape_for_gsub(prefix), "")
end

function string.strip_suffix(s, suffix)
   return string.gsub(s, escape_for_gsub(suffix) .. "$", "")
end
