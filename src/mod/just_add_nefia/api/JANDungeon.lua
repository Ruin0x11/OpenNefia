local WaveFunctionMap = require("mod.wfc.api.WaveFunctionMap")
local Dungeon = require("mod.elona.api.Dungeon")
local Pos = require("api.Pos")
local Feat = require("api.Feat")
local Queue = require("api.Queue")
local AStar = require("mod.just_add_nefia.api.AStar")
local Log = require("api.Log")
local Rand = require("api.Rand")

local JANDungeon = {}

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

function JANDungeon.detect_rooms(map)
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

function JANDungeon.calc_room_centroid(room)
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

function JANDungeon.dig_path_between(map, start_x, start_y, end_x, end_y, cache, tile, no_diagonal)
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

   local access = AStar.make_access_table(map)

   local path = AStar.path(start_x, start_y, end_x, end_y, access, cache, a_star_is_valid, a_star_cost)
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

function JANDungeon.connect_isolated_rooms(map, no_diagonal, tile)
   local rooms = JANDungeon.detect_rooms(map)
   local centroids = fun.iter(rooms)
      :map(JANDungeon.calc_room_centroid)
      :map(function(x, y) return { x = x, y = y } end)
      :to_list()
   local cache = {}

   for i = 1, #centroids-1 do
      local prev_centroid = centroids[i]
      local next_centroid = centroids[i+1]

      JANDungeon.dig_path_between(map, prev_centroid.x, prev_centroid.y, next_centroid.x, next_centroid.y, cache, tile, no_diagonal)
   end
end

--- Utility function to connect pockets of open space closed off on all sides in
--- a map. This is useful for wave function collapse templates, which sometimes
--- generate a lot of them.
function JANDungeon.connect_mazey_rooms(map, tile_id)
   tile_id = tile_id or "elona.mapgen_tunnel"

   local rooms = JANDungeon.detect_rooms(map)
   local room_map = {}
   for room_no, tiles in ipairs(rooms) do
      for _, tile in ipairs(tiles) do
         room_map[tile.y] = room_map[tile.y] or {}
         room_map[tile.y][tile.x] = room_no
      end
   end

   local room_to_connection = fun.range(#rooms):to_list()

   for room_no, room in ipairs(rooms) do
      local done = false
      for _, tile in ipairs(room) do
         for dx = -1, 1 do
            for dy = -1, 1 do
               local tx, ty = tile.x + dx, tile.y + dy
               if (dx == 0 or dy == 0) and not map:can_access(tx, ty) then
                  local ox = tile.x + dx * 2
                  local oy = tile.y + dy * 2
                  local other_room_no = room_map[oy] and room_map[oy][ox]
                  if other_room_no then
                     local our_room_connection = room_to_connection[room_no]
                     local other_room_connection = room_to_connection[other_room_no]
                     if other_room_connection ~= our_room_connection then
                        local new_connection = math.min(other_room_connection, our_room_connection)
                        room_to_connection[room_no] = new_connection
                        room_to_connection[other_room_no] = new_connection
                        map:set_tile(tx, ty, tile_id)
                        room_map[ty] = room_map[ty] or {}
                        room_map[ty][tx] = new_connection
                        table.insert(rooms[new_connection], { x = tx, y = ty, can_access = true })
                        done = true
                        break
                     end
                  end
               end
            end
            if done then
               break
            end
         end
         if done then
            break
         end
      end
   end
end

local function is_tunnel(map, x, y)
   return map:tile(x, y)._id == "elona.mapgen_tunnel"
end

function JANDungeon.place_stairs_in_maze(map, valid_tile_cb)
   local up_x, up_y, down_x, down_y
   local found = false
   local cache = {}

   valid_tile_cb = valid_tile_cb or is_tunnel

   local function a_star_is_valid(node, neighbor)
      return node.can_access
         and neighbor.can_access
         and Pos.dist(node.x, node.y, neighbor.x, neighbor.y) <= 1
   end

   local function a_star_cost(node_a, node_b)
      return Pos.dist(node_a.x, node_a.y, node_b.x, node_b.y)
   end

   local access = AStar.make_access_table(map)

   for _ = 0, 1000 do
      up_x = Rand.rnd(map:width())
      up_y = Rand.rnd(map:height())
      if valid_tile_cb(map, up_x, up_y) then
         down_x = Rand.rnd(map:width())
         down_y = Rand.rnd(map:height())
         if valid_tile_cb(map, down_x, down_y) then
            if Pos.dist(up_x, up_y, down_x, down_y) >= 10 then
               if AStar.path(up_x, up_y, down_x, down_y, access, cache, a_star_is_valid, a_star_cost) then
                  found = true
                  break
               end
            end
         end
      end
   end

   if not found then
      return false
   end

   Feat.create("elona.stairs_up", up_x, up_y, {}, map)
   Feat.create("elona.stairs_down", down_x, down_y, {}, map)

   return true
end

function JANDungeon.gen_maze(floor, params)
   local layout =
      {
         tiles = [[
.....####...#..#
.###.#..#.######
.#...#.####...#.
.#####.#....#.##
...#...####.###.
######....#.#.##
.....#..#.#.#.#.
######..#...#.#.
........#####.##
###.###..#....#.
..#.#...########
.##.#.#.#..#.#..
....###.##.#.##.
##..#......#..##
.########..##..#
........#...#..#]],
         tileset = {
            ["."] = "elona.mapgen_tunnel",
            ["#"] = "elona.mapgen_wall"
         }
      }

   local map = WaveFunctionMap.generate_overlapping(layout, params.width, params.height)
   if map == nil then
      return nil
   end

   map.max_crowd_density = map:width() * map:height() / 20

   for _, x, y in Pos.iter_border(0, 0, map:width() - 1, map:height() - 1) do
      map:set_tile(x, y, "elona.mapgen_wall")
   end

   JANDungeon.connect_mazey_rooms(map)
   if not JANDungeon.place_stairs_in_maze(map) then
      return nil
   end

   return map
end

function JANDungeon.gen_mazelike(floor, params)
   local layout =
      {
         tiles = [[
................
.####.#########.
.#....#.......#.
.#.####.#####.#.
.#.#....#...#.#.
...#.####.#.#.#.
.###.#......#.#.
.#...#.####.#.#.
.#.###.#..#.#.#.
.#.#...#..#.#.#.
.#.#.#.####.#.#.
.#.#........#.#.
.#.########.#.#.
.#........#.#.#.
.##########.###.
................]],
         tileset = {
            ["."] = "elona.mapgen_tunnel",
            ["#"] = "elona.mapgen_wall"
         }
      }

   local map = WaveFunctionMap.generate_overlapping(layout, params.width, params.height)
   if map == nil then
      return nil
   end

   map.max_crowd_density = map:width() * map:height() / 20

   for _, x, y in Pos.iter_border(0, 0, map:width() - 1, map:height() - 1) do
      map:set_tile(x, y, "elona.mapgen_wall")
   end

   JANDungeon.connect_mazey_rooms(map)
   if not JANDungeon.place_stairs_in_maze(map) then
      return nil
   end

   return map
end

local function try_place_door(map, x, y)
   if x <= 0 or y <= 0 or x >= map:width()-1 or y >= map:height()-1 then
      return
   end
   if map:tile(x, y)._id ~= "elona.mapgen_tunnel" then
      return
   end
   if Feat.at(x, y, map):length() > 0 then
      return
   end

   if (map:tile(x - 1, y)._id == "elona.mapgen_tunnel" and map:tile(x + 1, y)._id == "elona.mapgen_room")
      or (map:tile(x - 1, y)._id == "elona.mapgen_room" and map:tile(x + 1, y)._id == "elona.mapgen_tunnel")
   then
      if not map:is_floor(x, y - 1) and not map:is_floor(x, y + 1) then
         Feat.create("elona.door", x, y, {difficulty = Dungeon.calc_door_difficulty(map)}, map)
      end

      return
   end

   if (map:tile(x, y - 1)._id == "elona.mapgen_tunnel" and map:tile(x, y + 1)._id == "elona.mapgen_room")
      or (map:tile(x, y - 1)._id == "elona.mapgen_room" and map:tile(x, y + 1)._id == "elona.mapgen_tunnel")
   then
      if not map:is_floor(x - 1, y) and not map:is_floor(x + 1, y) then
         Feat.create("elona.door", x, y, {difficulty = Dungeon.calc_door_difficulty(map)}, map)
      end

      return
   end
end

function JANDungeon.gen_putit(floor, params)
   local layout = {
      tiles = [[
OO##OOOOOOOOOOOOOOOOOOOOO##OO
O#..#OOOOOOOOOOOOOOOOOOO#..#O
O#...#######OOOOO#######...#O
O#..........#OOO#..........#O
O#....x...x..###..x...x....#O
x#....x...x..###..x...x....#x
O#....x...x..###..x...x....#O
O#...........###...........#O
O#...........###...........#O
OO##........#OOO#........##OO
OOOO########OOOOO########OOOO]],

      tileset = {
         ["."] = "elona.mapgen_room",
         ["#"] = "elona.mapgen_default",
         ["O"] = "elona.mapgen_wall",
         ["x"] = "elona.mapgen_tunnel",
      }
   }

   local map = WaveFunctionMap.generate_overlapping(layout, params.width, params.height)
   if map == nil then
      return nil
   end

   map.max_crowd_density = map:width() * map:height() / 20

   for _, x, y in Pos.iter_border(0, 0, map:width() - 1, map:height() - 1) do
      map:set_tile(x, y, "elona.mapgen_wall")
   end

   JANDungeon.connect_isolated_rooms(map)
   if not JANDungeon.place_stairs_in_maze(map) then
      return nil
   end

   for _, x, y in map:iter_tiles() do
      try_place_door(map, x, y)
   end

   return map
end

function JANDungeon.gen_roomed(floor, params)
   local layout = {
      tiles = [[
...o....
.##o#ww.
.#ooopww
ooooopww
.##o#.w.
...o....]],
      tileset = {
         ["#"] = "elona.wall_palace_2_top",
         ["."] = "elona.wood_floor_5",
         ["p"] = "elona.palace_fountain",
         ["w"] = "elona.water",
         ["o"] = "elona.grey_floor"
      }
   }

   local map = WaveFunctionMap.generate_overlapping(layout, 30, 30)
   if map == nil then
      return nil
   end

   map.max_crowd_density = map:width() * map:height() / 20

   local is_valid = function(map, x, y) return map:tile(x, y)._id == "elona.wood_floor_5" end
   if not JANDungeon.place_stairs_in_maze(map, is_valid) then
      return nil
   end

   return map
end

function JANDungeon.gen_firey_life(floor, params)
   local gen = Dungeon.gen_type_puppy_cave
   if Rand.one_in(2) then
      gen = Dungeon.gen_type_big_room
   end

   local map = gen(floor, params)
   map:set_archetype("just_add_nefia.firey_life", { set_properties = true })

   map.max_crowd_density = map:width() * map:height() / 20

   return map
end

return JANDungeon
