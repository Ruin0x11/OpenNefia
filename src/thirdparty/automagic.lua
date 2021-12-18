
local autotable__newindex = function(self, key, value)
   local mt = getmetatable(self)
   mt.order[#mt.order+1] = key
   rawset(self, key, value)
end

-- index function to do the magic
local autotable__index = function(self, key)
   local mt = getmetatable(self)
   local t = {}
   if mt.depth ~= 1 then
      setmetatable(t, { __index = mt.__index, __newindex = autotable__newindex, depth = mt.depth - 1, order = {}})
   end
   self[key] = t
   return t
end

--- Creates a new auto-table.
-- @param depth (optional, default 1) how deep to auto-generate tables. The last
-- table in the chain generated will itself not be an auto-table. If `depth == 0` then
-- there is no limit.
-- @return new auto-table
function autotable(depth)
   return setmetatable({}, {__index = autotable__index, __newindex = autotable__newindex, depth = depth or 0, order = {} })
end

return autotable
