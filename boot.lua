function string.nonempty(s)
   return type(s) == "string" and s ~= ""
end

function math.clamp(i, min, max)
   return math.min(max, math.max(min, i))
end
