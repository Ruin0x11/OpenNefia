local map = require("internal.map")

-- Concerns anything that has to do with map querying/manipulation.
-- @module Map
local Map = {}

function Map.width()
   return map.get().width
end

function Map.height()
   return map.get().height
end

function Map.is_in_bounds(x, y)
   return map.get():is_in_bounds(x, y)
end

function Map.has_los(x1, y1, x2, y2)
   return map.get():is_in_fov(x1, y1, x2, y2)
end

function Map.is_in_fov(x, y)
   return map.get():is_in_fov(x, y)
end

function Map.can_access(x, y)
   return map.get():can_access(x, y)
end

function Map.tile(x, y)
   return map.get():tile(x, y)
end

function Map.set_tile(id, x, y)
   return map.get():set_tile(id, x, y)
end

return Map
