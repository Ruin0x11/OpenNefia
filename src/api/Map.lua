local field = require("game.field")
local data = require("internal.data")

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
   local Chara = require("api.Chara")
   return Map.is_in_bounds(x, y)
      and field.map:can_access(x, y)
      and Chara.at(x, y) == nil
end

function Map.tile(x, y)
   return field.map:tile(x, y)
end

function Map.set_tile(x, y, id)
   local tile = data["base.map_tile"][id]
   if tile == nil then return end

   return field.map:set_tile(x, y, tile)
end

function Map.iter_charas()
   return field.map:iter_charas()
end

-- TODO: way of accessing map variables without exposing internals

return Map
