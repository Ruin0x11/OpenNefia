local utils = {}

local COMPARATORS = {
   ["<"]  = function(a, b) return a <  b end,
   ["<="] = function(a, b) return a <= b end,
   ["=="] = function(a, b) return a == b end,
   [">="] = function(a, b) return a >= b end,
   [">"]  = function(a, b) return a >  b end,
}

function utils.compare(a, comp, b)
   local comparator = COMPARATORS[comp]
   if comparator == nil then
      error("unknown comparator ".. tostring(comp))
   end
   return comparator(a, b)
end

return utils
