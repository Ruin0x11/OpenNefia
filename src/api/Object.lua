local IObject = require("api.IObject")

local Object = {}

-- Modification of penlight's algorithm to ignore class fields
local function cycle_aware_copy(t, cache)
   -- TODO: standardize no-save fields
   if type(t) == "table" and t.__class then
      return
   end

   if type(t) ~= 'table' then return t end
   if cache[t] then return cache[t] end
   local res = {}
   cache[t] = res
   local mt = getmetatable(t)
   for k,v in pairs(t) do
      -- TODO: standardize no-save fields
      -- NOTE: preserves the UID for now.
      if k ~= "location" then
         k = cycle_aware_copy(k, cache)
         v = cycle_aware_copy(v, cache)
         res[k] = v
      end
   end
   setmetatable(res,mt)
   return res
end

--- Strips any classes and extracts only the fields and underlying
--- prototype of an object to a table. The returned table can then be
--- passed to Object.generate to build a new copy of the original
--- object, as MapObject.clone does.
-- @tparam IObject object
-- @treturn table
function Object.make_prototype(object)
   return cycle_aware_copy(object, {})
end

--- Wraps a table with the object metatable.
function Object.create(tbl)
   local obj = setmetatable(tbl, IObject)
   self:build()
   return obj
end

return Object
