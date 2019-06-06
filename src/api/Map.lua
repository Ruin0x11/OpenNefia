local field = require("game.field")

-- Concerns anything that has to do with map querying/manipulation.
-- @module Map
local Map = {}

function Map.width()
   return field.map.width
end

function Map.height()
   return field.map.height
end

function Map.is_in_bounds(x, y)
   return field.map:is_in_bounds(x, y)
end

function Map.has_los(x1, y1, x2, y2)
   return field.map:is_in_fov(x1, y1, x2, y2)
end

function Map.is_in_fov(x, y)
   return field.map:is_in_fov(x, y)
end

function Map.can_access(x, y)
   return field.map:can_access(x, y)
end

function Map.tile(x, y)
   return field.map:tile(x, y)
end

function Map.set_tile(id, x, y)
   return field.map:set_tile(id, x, y)
end

return Map
