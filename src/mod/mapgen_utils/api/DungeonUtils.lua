local Queue = require("api.Queue")
local Pos = require("api.Pos")
local Log = require("api.Log")
local AStar = require("mod.extlibs.api.AStar")

local DungeonUtils = {}

local function flood_room(x, y, map, seen)
   if not (map:is_in_bounds(x, y) and map:can_access(x, y)) then
      return
   end

   local room = {}

   local function flood(x, y)
      if not (map:is_in_bounds(x, y) and map:can_access(x, y)) then
         return
      end

      local ind = y * map:width() + x + 1
      if seen[ind] then
         return
      end
      seen[ind] = true

      room[#room+1] = { x = x, y = y }
      flood(x+1, y)
      flood(x, y-1)
      flood(x-1, y)
      flood(x, y+1)
   end
   flood(x, y)

   return room
end

function DungeonUtils.detect_rooms(map)
   local w = map:width()
   local seen = {}
   local rooms = {}
   local queue = Queue:new()

   for _, x, y in map:iter_tiles() do
      if map:can_access(x, y) then
         queue:push { x = x, y = y }
      end
   end

   while queue:len() > 0 do
      local tile = queue:pop()
      local ind = tile.y * w + tile.x + 1
      if not seen[ind] then
         rooms[#rooms+1] = flood_room(tile.x, tile.y, map, seen)
      end
   end

   return rooms
end

function DungeonUtils.calc_room_centroid(room)
   local function add(acc, pt)
      acc.x = acc.x + pt.x
      acc.y = acc.y + pt.y
      return acc
   end

   local pt = fun.iter(room):foldl(add, { x = 0, y = 0 })
   pt.x = math.floor(pt.x / #room)
   pt.y = math.floor(pt.y / #room)

   return pt.x, pt.y
end

function DungeonUtils.dig_path_between(map, start_x, start_y, end_x, end_y, cache, tile, no_diagonal)
   tile = tile or "elona.mapgen_tunnel"

   local function a_star_is_valid(node, neighbor)
      local dx = math.abs(node.x - neighbor.x)
      local dy = math.abs(node.y - neighbor.y)
      if no_diagonal and dx > 0 and dy > 0 then
         return false
      end
      return Pos.dist(node.x, node.y, neighbor.x, neighbor.y) <= 1
   end

   local function a_star_cost(node_a, node_b)
      local dist = Pos.dist(node_a.x, node_a.y, node_b.x, node_b.y)
      local dx = math.abs(node_a.x - node_b.x)
      local dy = math.abs(node_a.y - node_b.y)
      if dx > 0 and dy > 0 then
         dist = dist * 100
      end
      if not node_a.can_access then
         dist = dist * 10
      end
      if not node_b.can_access then
         dist = dist * 10
      end
      return dist
   end

   local astar = AStar:new(map, cache, a_star_is_valid, a_star_cost)

   local path = astar:path(start_x, start_y, end_x, end_y)
   if not path then
      Log.warn("no path")
      return
   end

   for _, node in ipairs(path) do
      if not map:can_access(node.x, node.y) then
         map:set_tile(node.x, node.y, tile)
      end
   end
end

function DungeonUtils.connect_isolated_rooms(map, no_diagonal, tile)
   local rooms = DungeonUtils.detect_rooms(map)
   local centroids = fun.iter(rooms)
      :map(DungeonUtils.calc_room_centroid)
      :map(function(x, y) return { x = x, y = y } end)
      :to_list()
   local cache = {}

   for i = 1, #centroids-1 do
      local prev_centroid = centroids[i]
      local next_centroid = centroids[i+1]

      DungeonUtils.dig_path_between(map, prev_centroid.x, prev_centroid.y, next_centroid.x, next_centroid.y, cache, tile, no_diagonal)
   end
end

return DungeonUtils
