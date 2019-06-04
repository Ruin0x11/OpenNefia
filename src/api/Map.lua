-- Concerns anything that has to do with map querying/manipulation.
-- @module Map
local Map = {}

function Map.width()
   return 40
end

function Map.height()
   return 40
end

function Map.in_bounds(x, y)
   return x >= 0 and y >= 0 and x < Map.width() and y < Map.height()
end

function Map.can_access(x, y)
   return Map.in_bounds(x, y)
end

return Map
