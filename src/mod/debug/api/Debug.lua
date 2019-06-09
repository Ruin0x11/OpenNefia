local Map = require("api.Map")

local Debug = {}

local function right_pad(str, len)
    return str .. string.rep(' ', len - #str)
end

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

function Debug.print_table(t, header)
   if not (t[1] ~= nil and t[1][1] ~= nil) then
      error("must be 2D-array-like table")
   end

   local columns = #t[1]
   local widths = table.of(0, columns)

   if header then
      for j, item in ipairs(header) do
         widths[j] = math.max(widths[j], utf8.wide_len(item))
      end
   end

   for i, row in ipairs(t) do
      for j, item in ipairs(row) do
         widths[j] = math.max(widths[j], utf8.wide_len(tostring(item)))
      end
   end

   local total_width = table.reduce(widths, function(sum, n) return sum + n + 1 end, 0)

   local s = ""

   if header then
      for j, item in ipairs(header) do
         s = s .. string.format("%s ", right_pad(item, widths[j]))
      end
      s = s .. "\n" .. string.rep('-', total_width) .. "\n"
   end

   for i, row in ipairs(t) do
      for j, item in ipairs(row) do
         s = s .. string.format("%s ", right_pad(tostring(item), widths[j]))
      end
      s = s .. "\n"
   end

   return s
end

function Debug.dump_charas()
   local t = {}
   for _, c in Map.iter_charas() do
      t[#t+1] = { tostring(c.uid), c.x, c.y }
   end

   return Debug.print_table(t, {"UID", "X", "Y"})
end

return Debug
