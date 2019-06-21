local Rand = require("api.Rand")

-- Functions dealing with 2D tiled map positions.
-- @module Pos
local Pos = {}

local directions = {
   North     = {  0, -1 },
   South     = {  0,  1 },
   East      = { -1,  0 },
   West      = {  1,  0 },
   Northeast = { -1, -1 },
   Southeast = { -1,  1 },
   Northwest = {  1, -1 },
   Southwest = {  1,  1 },
}

local directions_rev = {
   [-1] = { [-1] = "Northwest", [0] = "North", [1] = "Northeast" },
   [0]  = { [-1] = "West",                     [1] = "East"      },
   [1]  = { [-1] = "Southwest", [0] = "South", [1] = "Southeast" },
}

function Pos.unpack_direction(dir)
   local dir = directions[dir]
   if dir then
      return dir[1], dir[2]
   else
      return 0, 0
   end
end

function Pos.pack_direction(dx, dy)
   local it = directions_rev[dy]
   if not it then
      return nil
   end
   return it[dx]
end

function Pos.add_direction(dir, x, y)
   local dir = directions[dir]
   if dir then
      return x + dir[1], y + dir[2]
   else
      return x, y
   end
end

function Pos.random_direction(x, y)
   return Rand.rnd(3) - 1 + x, Rand.rnd(3) - 1 + y
end

function Pos.dist(x1, y1, x2, y2)
   local dx = x1 - x2
   local dy = y1 - y2
   return math.sqrt(dx * dx + dy * dy)
end

function Pos.direction_in(start_x, start_y, finish_x, finish_y)
   local nx = 0
   local ny = 0
   if finish_x > start_x then
      nx = nx + 1
   elseif finish_x < start_x then
      nx = nx - 1
   end
   if finish_y > start_y then
      ny = ny + 1
   elseif finish_y < start_y then
      ny = ny - 1
   end

   return nx, ny
end

function Pos.is_in_square(x, y, center_x, center_y, perimeter)
   local half = math.floor(perimeter / 2)
   return x > center_x - half and x < center_x + half
      and y > center_y - half and y < center_y + half
end

return Pos
