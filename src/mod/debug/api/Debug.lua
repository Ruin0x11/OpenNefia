local Map = require("api.Map")

local Debug = {}

--- Reduces an array-like table over a function.
-- @tparam array arr
-- @tparam func f
-- @tparam any start
-- @treturn any
function table.reduce(arr, f, start)
   local result = start

   for _, v in ipairs(arr) do
      result = f(result, v)
   end

   return result
end

function Debug.dump_charas()
   local t = {}
   for _, c in Map.iter_charas() do
      t[#t+1] = { tostring(c.uid), c.x, c.y }
   end

   return table.print(t, {"UID", "X", "Y"})
end

function Debug.dump_items()
   local t = {}
   for _, i in Map.iter_items() do
      t[#t+1] = { tostring(i.uid), i.x, i.y }
   end

   return table.print(t, {"UID", "X", "Y"})
end

return Debug
