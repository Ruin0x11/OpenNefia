--- Functions dealing with 2D tiled map positions.
--- @module Pos
local Rand = require("api.Rand")

local Pos = {}

local directions = {
   North     = {  0, -1 },
   South     = {  0,  1 },
   East      = {  1,  0 },
   West      = { -1,  0 },
   Northeast = {  1, -1 },
   Southeast = {  1,  1 },
   Northwest = { -1, -1 },
   Southwest = { -1,  1 },
   Center    = {  0,  0 },
}

local directions_rev = { [-1] = {}, [0] = {}, [1] = {} }

for name, pos in pairs(directions) do
   directions_rev[pos[2]][pos[1]] = name
end

--- Converts a direction to a pair of (dx, dy), or (0, 0) on failure.
---
--- @tparam direction dir
--- @treturn int x
--- @treturn int y
function Pos.unpack_direction(dir)
   local dir = directions[dir]
   if dir then
      return dir[1], dir[2]
   else
      return 0, 0
   end
end

--- Converts a pair of (dx, dy) to a direction, or nil on failure.
---
--- @tparam int dx
--- @tparam int dy
--- @treturn direction
function Pos.pack_direction(dx, dy)
   local it = directions_rev[dy]
   if not it then
      return nil
   end
   return it[dx]
end

--- Offsets a pair of (x, y) by a direction.
---
--- @tparam direction dir
--- @tparam int x
--- @tparam int y
--- @treturn int x
--- @treturn int y
function Pos.add_direction(dir, x, y)
   local dir = directions[dir]
   if dir then
      return x + dir[1], y + dir[2]
   else
      return x, y
   end
end

--- Returns a random position next to (x, y).
---
--- @tparam int x
--- @tparam int y
--- @treturn int x
--- @treturn int y
function Pos.random_direction(x, y)
   return Rand.rnd(3) - 1 + x, Rand.rnd(3) - 1 + y
end

--- Returns a random position in a cardinal direction from (x, y).
---
--- @tparam int x
--- @tparam int y
--- @treturn int x
--- @treturn int y
function Pos.random_cardinal_direction(x, y)
   return Rand.rnd(3) - 1 + x, Rand.rnd(3) - 1 + y
end

--- Returns the distance between two points.
---
--- @tparam int x1
--- @tparam int y1
--- @tparam int x2
--- @tparam int y2
--- @treturn int
function Pos.dist(x1, y1, x2, y2)
   local dx = x1 - x2
   local dy = y1 - y2
   return math.sqrt(dx * dx + dy * dy)
end

--- Returns the direction offset of two positions as a unit vector of
--- (dx, dy).
---
--- @tparam int start_x
--- @tparam int start_y
--- @tparam int finish_x
--- @tparam int finish_y
--- @treturn int dx
--- @treturn int dy
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

--- True if a point is in a centered square.
---
--- @tparam int x
--- @tparam int y
--- @tparam int center_x
--- @tparam int center_y
--- @tparam in perimeter
--- @treturn bool
function Pos.is_in_square(x, y, center_x, center_y, perimeter)
   local half = math.floor(perimeter / 2)
   return x > center_x - half and x < center_x + half
      and y > center_y - half and y < center_y + half
end

--- Iterates random points between two points. If no positions are
--- given, defaults to iterating random positions on the current map.
---
--- @tparam int start_x
--- @tparam int start_y
--- @tparam int end_x
--- @tparam int end_y
--- @treturn Iterator(int,int)
function Pos.iter_random(start_x, start_y, end_x, end_y)
   if start_x == nil then
      local Map = require("api.Map")
      start_x = 0
      start_y = 0
      end_x = Map.width()
      end_y = Map.height()
   end

   local gen = function() return Rand.between(start_x, end_x), Rand.between(start_y, end_y) end
   return fun.tabulate(gen)
end

local function iter_rect(state, pos)
   local old = pos
   pos.x = pos.x + 1
   if pos.x == state.end_x then
      pos.x = state.start_x
      pos.y = pos.y + 1
      if pos.y == state.end_y then
         return nil, nil
      end
   end

   return pos, old.x, old.y
end

--- Iterates points in a rectangle.
---
--- @tparam int start_x
--- @tparam int start_y
--- @tparam int end_x
--- @tparam int end_y
--- @treturn Iterator(int,int)
function Pos.iter_rect(start_x, start_y, end_x, end_y)
   return fun.wrap(iter_rect, {start_x=start_x,end_x=end_x+1,end_y=end_y+1}, {x=start_x-1,y=start_y})
end

local function iter_circle(state, pos)
   local old_x, old_y = pos.x + state.ox, pos.y + state.oy
   local found = false
   while not found do
      old_x, old_y = pos.x + state.ox, pos.y + state.oy
      pos.x = pos.x + 1
      if pos.x == state.diameter then
         pos.x = 0
         pos.y = pos.y + 1
         if pos.y == state.diameter then
            return nil
         end
      end

      found = state.cache[pos.x][pos.y]
   end

   return pos, old_x, old_y
end

--- Iterates points in a circle.
---
--- @tparam int ox
--- @tparam int oy
--- @tparam int diameter
--- @treturn Iterator(int,int)
function Pos.iter_circle(ox, oy, diameter)
   local cache = {}

   local radius = math.floor((diameter + 2) / 2)
   local max_dist = math.floor(diameter / 2)

   for x=0,diameter+1 do
      cache[x] = {}
      for y=0,diameter+1 do
         cache[x][y] = Pos.dist(x, y, radius, radius) < max_dist - 1
      end
   end

   return fun.wrap(iter_circle, {cache=cache,diameter=diameter,ox=ox-radius,oy=oy-radius}, {x=0,y=0})
end

local function iter_line(state, index)
   if index.x == state.end_x and index.y == state.end_y then
      return nil
   end

   local e = index.err + index.err
   if e > -state.bound_y then
      index.err = index.err - state.bound_y
      index.x = index.x + state.delta_x
   end
   if e < state.bound_x then
      index.err = index.err + state.bound_x
      index.y = index.y + state.delta_y
   end

   return index, index.x, index.y
end

--- Iterates points in a line. You can pass a callback for stopping
--- the iteration if a solid tile is encountered.
---
--- @tparam int start_x
--- @tparam int start_y
--- @tparam int end_x
--- @tparam int end_y
--- @treturn Iterator(int,int)
function Pos.iter_line(start_x, start_y, end_x, end_y)
   local delta_x, delta_y, bound_x, bound_y

   if start_x < end_x then
      delta_x = 1
      bound_x = end_x - start_x
   else
      delta_x = -1
      bound_x = start_x - end_x
   end

   if start_y < end_y then
      delta_y = 1
      bound_y = end_y - start_y
   else
      delta_y = -1
      bound_y = start_y - end_y
   end

   local state = { delta_x = delta_x, delta_y = delta_y, bound_x = bound_x, bound_y = bound_y, end_x = end_x, end_y = end_y }
   local index = { x = start_x, y = start_y, err = bound_x - bound_y }

   return fun.wrap(iter_line, state, index)
end

local function iter_bolt(state, pos)
   local old_x, old_y = pos.x, pos.y
   if state.is_solid(pos.x + pos.dx, pos.y) then
      pos.dx = -pos.dx
   elseif state.is_solid(pos.x, pos.y + pos.dy) then
      pos.dy = -pos.dy
   end
   pos.x = pos.x + pos.dx
   pos.y = pos.y + pos.dy

   return pos, old_x, old_y
end

local function iter_beam(state, pos)
   local old_x, old_y = pos.x, pos.y
   if state.is_solid(pos.x, pos.y) then
      return nil
   end
   pos.x = pos.x + pos.dx
   pos.y = pos.y + pos.dy

   return pos, old_x, old_y
end

local function gen_line(cb)
   return function(start_x, start_y, dx, dy, is_solid_cb)
      dx = math.sign(dx)
      dy = math.sign(dy)

      if is_solid_cb == nil then
         local Map = require("api.Map")
         is_solid_cb = function(x, y) return not Map.current():can_access(x, y) end
      end

      if dx == 0 and dy == 0 then
         return fun.iter({})
      end

      return fun.wrap(cb, {is_solid=is_solid_cb}, {x=start_x+dx,y=start_y+dy,dx=dx,dy=dy})
   end
end

--- Iterates points in a bolt, which bounces off solid tiles. You can
--- pass a callback for stopping the iteration if a solid tile is
--- encountered.
---
--- @function Pos.iter_bolt
--- @tparam int start_x
--- @tparam int start_y
--- @tparam int dx
--- @tparam int dy
--- @tparam[opt] function is_solid_cb Defaults to InstancedMap.can_access
--- @treturn Iterator(int,int)
Pos.iter_bolt = gen_line(iter_bolt)

--- Iterates points in a beam, which travels in a straight line at 45
--- degree angles only. You can pass a callback for stopping the
--- iteration if a solid tile is encountered.
---
--- @function Pos.iter_bolt
--- @tparam int start_x
--- @tparam int start_y
--- @tparam int dx
--- @tparam int dy
--- @tparam[opt] function is_solid_cb Defaults to InstancedMap.can_access
--- @treturn Iterator(int,int)
Pos.iter_beam = gen_line(iter_beam)

local function iter_surrounding(state, pos)
   if pos.y > 1 then
      return nil
   end

   local x, y = pos.x + state.x, pos.y + state.y

   pos.x = pos.x + 1
   if pos.x > 1 then
      pos.x = -1
      pos.y = pos.y + 1
   end

   if pos.x == 0 and pos.y == 0 then
      pos.x = pos.x + 1
   end

   return pos, x, y
end

--- Iterates points surrounding a position.
---
--- @tparam int x
--- @tparam int y
--- @treturn Iterator(int,int)
function Pos.iter_surrounding(x, y)
   return fun.wrap(iter_surrounding, {x=x,y=y},{x=-1,y=-1})
end

return Pos
