local Feat = require("api.Feat")
local Pos = require("api.Pos")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")
local Rand = require("api.Rand")

-- functions for nefia generation used by Elona 1.22's map generators.
local Dungeon = {}

local room_kinds = {
   [0] = {
      pos = "0",
      wall = "0",
      door = "0",
   },
   [1] = {
      pos = "1",
      wall = "1",
      door = "0",
   },
   [2] = {
      pos = "2",
      wall = "1",
      door = "1",
   },
   [3] = {
      pos = "3",
      wall = "2",
      door = "3",
   },
   [4] = {
      pos = "4",
      wall = "3",
      door = "0",
   },
}

function Dungeon.calc_room_size(pos, min_size, max_size, map_width, map_height)
   local x, y, w, h, dir

   if pos == "0" then
      -- room anywhere
      w = Rand.rnd(min_size, min_size + max_size)
      h = Rand.rnd(min_size, min_size + max_size)
      x = Rand.rnd(map_width) + 2
      y = Rand.rnd(map_height) + 2
   elseif pos == "1" then
      -- room anywhere, away from edges
      w = math.floor(Rand.rnd(min_size, min_size + max_size) / 3 * 3) + 5
      h = math.floor(Rand.rnd(min_size, min_size + max_size) / 3 * 3) + 5
      x = math.floor(Rand.rnd(map_width) / 3 * 3) + 2
      y = math.floor(Rand.rnd(map_height) / 3 * 3) + 2
   elseif pos == "2" then
      -- room on the edge
      dir = Rand.rnd(4)
      if dir == 3 or dir == 0 then
         x = Rand.rnd(math.floor(map_width - min_size * 3 / 2 - 2)) + math.floor(min_size / 2)
         w = Rand.rnd(min_size) + math.floor(min_size / 2) + 3
         h = min_size
         if dir == 3 then
            y = 0
         else
            y = map_height - h
         end
      else
         y = Rand.rnd(math.floor(map_height - min_size * 3 / 2 - 2)) + math.floor(min_size / 2)
         w = min_size
         h = Rand.rnd(min_size) + math.floor(min_size / 2) + 3
         if dir == 1 then
            x = 0
         else
            x = map_width - w
         end
      end
   elseif pos == "3" then
      -- small fixed size room
      w = 3
      h = 3
      local x_range = map_width - min_size * 2 - w - 2 + 1
      if x_range < 1 then
         return nil
      end
      local y_range = map_height - min_size * 2 - h - 2 + 1
      if y_range < 1 then
         return nil
      end
      x = min_size + 1 + Rand.rnd(x_range)
      y = min_size + 1 + Rand.rnd(y_range)
   elseif pos == "4" then
      w = Rand.rnd(min_size, min_size + max_size)
      h = Rand.rnd(min_size, min_size + max_size)
      x = Rand.rnd(map_width - max_size - 8) + 3
      y = Rand.rnd(map_height - max_size - 8) + 3
   end

   return x, y, w, h, dir
end

function Dungeon.calc_valid_room(pos, min_size, max_size, rooms, map)
   map = map or Map.current()

   local map_width = map:width()
   local map_height = map:height()

   local x, y, w, h, dir

   for i = 1, 100 do
      local success = false

      while true do
         x, y, w, h, dir = Dungeon.calc_room_size(pos, min_size, max_size, map_width, map_height)

         if x == nil then
            return nil, "could not fit generated room"
         end

         local mx = x + w - 1
         local my = y + h - 1

         if mx >= map_width or my >= map_height then
            break
         end

         if pos == "1" then
            if mx >= map_width + 1 or my >= map_height + 1 then
               break
            end
         end

         if pos == "3" then
            if Map.tile(mx, my, map)._id ~= "elona_sys.mapgen_room" then
               break
            end
         end

         local do_continue = false
         for _, other in ipairs(rooms) do
            local x1 = other.x - 1 - x
            local y1 = other.y - 1 - y
            local x2 = -other.width - 2 < x1 and x1 < w
            local y2 = -other.height - 2 < y1 and y1 < h
            if x2 and y2 then
               do_continue = true
               break
            end
         end
         if do_continue then
            break
         end

         success = true
         break
      end

      if success then
         return {x = x, y = y, width = w, height = h, dir = dir}
      end
   end

   return nil, "gave up after 100 tries"
end

function Dungeon.dig_room(kind, min_size, max_size, rooms, params, map)
   local base = room_kinds[kind or 0]
   local params = table.merge_missing(params, base)

   local room = Dungeon.calc_valid_room(params.pos, min_size, max_size, rooms, map)
   if room == nil then
      return false
   end

   _p(room, params.pos)
   table.insert(rooms, room)

   local tile1 = 0
   if Rand.one_in(2) then
      tile1 = 1 + Rand.rnd(2)
   end
   local tile2 = 0
   if Rand.one_in(2) then
      tile2 = 1 + Rand.rnd(2)
   end

   for j=0, room.height-1 do
      local y = room.y + j
      for i=0, room.width-1 do
         local x = room.x + i

         local tile = "room"

         if params.wall ~= "0" then
            if i == 0 or j == 0 or i == room.width-1 or j == room.height - 1 then
               if params.wall == "1" then
                  tile = "wall"
               elseif params.wall == "2" then
                  tile = "floor_2"
               elseif params.wall == "3" then
                  tile = "room"
                  if tile1 == 1 and i == 0 then
                     tile = "wall"
                  end
                  if tile2 == 1 and j == 0  then
                     tile = "wall"
                     if i ~= 0 and i ~= room.width - 1 then
                        if Rand.one_in(3) then
                           print "itemcreate1"
                        elseif i % 2 == 1 then
                           print "itemcreate2"
                        end
                     end
                  end
                  if tile1 == 2 and i == room.width - 1 then
                     tile = "wall"
                  end
                  if tile2 == 2 and j == room.height - 1 then
                     tile = "wall"
                     if Rand.one_in(3) then
                        print "itemcreate3"
                     elseif i % 2 == 1 then
                        print "itemcreate4"
                     end
                  end
               end
            end
         end

         Map.set_tile(x, y, "elona_sys.mapgen_" .. tile, map)
      end
   end

   if params.door == "1" then
      Dungeon.create_room_door(room, nil, true, map)
   elseif params.door == "2" or params.door == "3" then
      for dir=0, 3 do
         Dungeon.create_room_door(room, dir, params.door ~= "3", map)
      end
   end

   return room
end

function Dungeon.create_room_door(room, dir, place_door, map)
   dir = dir or room.dir or 0

   local pos

   if dir == 3 or dir == 0 then
      pos = room.width
   else
      pos = room.height
   end

   local door_positions = {}

   for i=0, pos - 3 do
      door_positions[i] = i
   end

   door_positions = Rand.shuffle(door_positions)
   local dirs1 = {}
   local dirs2 = {}
   local x, y

   for _, pos in ipairs(door_positions) do
      if dir == 3 then
         x = pos + room.x + 1
         y = room.y + room.height - 1
         dirs1 = { 0, 0 }
         dirs2 = {-1, 1 }
      elseif dir == 0 then
         x = pos + room.x + 1
         y = room.y
         dirs1 = { 0, 0 }
         dirs2 = {-1, 1 }
      elseif dir == 1 then
         x = room.x + room.width - 1
         y = pos + room.y + 1
         dirs1 = {-1, 1 }
         dirs2 = { 0, 0 }
      elseif dir == 2 then
         x = room.x
         y = pos + room.y + 1
         dirs1 = {-1, 1 }
         dirs2 = { 0, 0 }
      end

      local success = true
      for i=1, 2 do
         local dx = x + dirs1[i]
         local dy = y + dirs2[i]
         if dx < 0 or dy < 0 or dx >= map:width() or dy >= map:height() then
            success = false
            break
         end
         -- if Map.tile(dx, dy, map)._id == "elona_sys.mapgen_wall" then
         --    success = false
         --    break
         -- end
      end

      if success then
         Map.set_tile(x, y, "elona_sys.mapgen_room", map)
         if place_door then
            local difficulty = Rand.rnd(math.floor(math.abs(map:calc("dungeon_level") * 3 / 2)) + 1)
            Feat.create("elona.door", x, y, {difficulty = difficulty}, map)
         end
         return true
      end
   end

   return false
end

function Dungeon.place_stairs_up(room, x, y, map)
   if not x then
      x = Rand.rnd(room.width - 2) + room.x + 1
      y = Rand.rnd(room.height - 2) + room.y + 1
      room.has_upstairs = true
   end

   return Feat.create("elona.stairs_up", x, y, {}, map)
end

function Dungeon.place_stairs_down(room, x, y, map)
   if map:calc("dungeon_level") >= map:calc("deepest_dungeon_level") then
      return nil
   end

   if not x then
      x = Rand.rnd(room.width - 2) + room.x + 1
      y = Rand.rnd(room.height - 2) + room.y + 1
      room.has_upstairs = true
   end

   return Feat.create("elona.stairs_down", x, y, {}, map)
end

local function calc_room_entrance(room, map)
   local x, y, dx, dy

   while true do
      local found = true
      local dir = Rand.choice({"North", "South", "East", "West"})
      dx, dy = Pos.unpack_direction(dir)

      if dir == "West" then
         x = room.x
         y = room.y + Rand.rnd(room.height - 2) + 1
      elseif dir == "East" then
         x = room.x + room.width - 1
         y = room.y + Rand.rnd(room.height - 2) + 1
      elseif dir == "South" then
         x = room.x + Rand.rnd(room.width - 2) + 1
         y = room.y
      elseif dir == "North" then
         x = room.x + Rand.rnd(room.width - 2) + 1
         y = room.y + room.height - 1
      end
      if x ~= 0 then
         if Map.tile(x, y - 1, map)._id == "elona_sys.mapgen_room" or Map.tile(x, y + 1, map)._id == "elona_sys.mapgen_room" then
            found = false
         end
      end
      if y ~= 0 then
         if Map.tile(x - 1, y, map)._id == "elona_sys.mapgen_room" or Map.tile(x + 1, y, map)._id == "elona_sys.mapgen_room" then
            found = false
         end
      end

      if found then
         break
      end
   end

   return x, y, dx, dy
end

function Dungeon.connect_rooms(rooms, place_doors, params, map)
   local room_idx = 1
   while room_idx < #rooms do
      local success = false
      for i = 1, Rand.rnd(params.room_entrance_count) + 1 do
         local start_x, start_y, end_x, end_y

         for j = room_idx, room_idx + 1 do
            local room = rooms[j]
            local x, y, dx, dy = calc_room_entrance(room, map)

            Map.set_tile(x, y, "elona_sys.mapgen_room", map)
            Map.set_tile(x + dx, y + dy, "elona_sys.mapgen_tunnel", map)
            if j == room_idx then
               start_x = x + dx
               start_y = y + dy
            else
               end_x = x + dx
               end_y = y + dy
            end
         end

         success = Dungeon.dig_to_entrance(start_x, start_y, end_x, end_y, true, params.hidden_path_chance, map)
      end

      if not success then
         return false
      end

      room_idx = room_idx + 1
   end

   return true
end

local function can_dig(x, y, map)
   if x < 0 or y < 0 or x >= map:width() or y >= map:height() then
      return false
   end

   local tile = Map.tile(x, y, map)
   return tile._id ~= "elona_sys.mapgen_tunnel" and tile._id ~= "elona_sys.mapgen_floor"
end

local function next_dir(dir, tx, ty, end_x, end_y, map)
   local dest

   if tx >= end_x - 4 and tx <= end_x + 4 and ty >= end_y - 4 and tx <= end_y + 4 then
      if tx < end_x then
         dir = 2
         if ty > end_y then
            dest = 3
         else
            dest = 0
         end
      end
      if tx > end_x then
         dir = 1
         if ty > end_y then
            dest = 3
         else
            dest = 0
         end
      end
      if ty < end_y then
         dir = 0
         if tx > end_x then
            dest = 1
         else
            dest = 2
         end
      end
      if ty > end_y then
         dir = 3
         if tx > end_x then
            dest = 1
         else
            dest = 2
         end
      end

      return dir, dest
   end

   if dir == 1 or dir == 2 then
      if ty > end_y then
         dir = 3
      else
         dir = 0
      end
      if tx > end_x then
         dir = 1
      else
         dir = 2
      end
   else
      if tx > end_x then
         dir = 1
      else
         dir = 2
      end
      if ty > end_y then
         dir = 3
      else
         dir = 0
      end
   end

   return dir, dest
end

local function next_dir_2(dir, last_dir, tx, ty, end_x, end_y, map)
   local function swap()
      if tx == end_x then
         local temp = last_dir
         last_dir = dir
         dir = temp
      else
         dir = last_dir
         last_dir = nil
      end
   end

   if last_dir then
      if last_dir == 1 and can_dig(tx - 1, ty, map) then
         swap()
      elseif last_dir == 2 and can_dig(tx + 1, ty, map) then
         swap()
      elseif last_dir == 3 and can_dig(tx, ty - 1, map) then
         swap()
      elseif last_dir == 0 and can_dig(tx, ty + 1, map) then
         swap()
      end
   end

   if (dir == 1 or dir == 2) then
      if tx == end_x  then
         if ty > end_y and can_dig(tx, ty - 1, map) then
            last_dir = dir
            dir = 3
         elseif ty < end_y and can_dig(tx, ty + 1, map) then
            last_dir = dir
            dir = 0
         end
      end
   else
      if ty == end_y  then
         if tx > end_x and can_dig(tx - 1, ty, map) then
            last_dir = dir
            dir = 1
         elseif tx < end_x and can_dig(tx + 1, ty, map) then
            last_dir = dir
            dir = 2
         end
      end
   end

   return dir, last_dir
end

function Dungeon.dig_to_entrance(start_x, start_y, end_x, end_y, straight, hidden_path_chance, map)
   local dest = -1
   local success = false
   local tx = start_x
   local ty = start_y
   local dx = 0
   local dy = 0
   local dir = 0
   local last_dir = nil

   if straight then
      dir, dest = next_dir(dir, tx, ty, end_x, end_y, map)
   end
   for i = 1, 2000 do
      if tx == end_x then
         if ty + 1 == end_y or ty - 1 == end_y then
            success = true
            break
         end
      end
      if ty == end_y then
         if tx + 1 == end_x or tx - 1 == end_x then
            success = true
            break
         end
      end
      if straight then
         dir, last_dir = next_dir_2(dir, last_dir, tx, ty, end_x, end_y, map)
      end

      dx = tx
      dy = ty

      if dir == 1 then
         dx = tx - 1
      elseif dir == 2 then
         dx = tx + 1
      elseif dir == 3 then
         dy = ty - 1
      elseif dir == 0 then
         dy = ty + 1
      end

      if can_dig(dx, dy, map) then
         tx = dx
         ty = dy
         Map.set_tile(dx, dy, "elona_sys.mapgen_tunnel", map)
         if Rand.rnd(200) < hidden_path_chance then
            Map.set_tile(dx, dy, "elona_sys.mapgen_floor_2", map)
            Feat.create("elona.hidden_path", dx, dy, {}, map)
         end
         if not straight and Rand.one_in(4) then
            dir, dest = next_dir(dir, tx, ty, end_x, end_y, map)
         end
      else
         if dest == 1 then
            if can_dig(tx - 1, ty, map) then
               dir = 1
               dest = -2
            end
         elseif dest == 2 then
            if can_dig(tx + 1, ty, map) then
               dir = 2
               dest = -2
            end
         elseif dest == 3 then
            if can_dig(tx, ty - 1, map) then
               dir = 3
               dest = -2
            end
         elseif dest == 0 then
            if can_dig(tx, ty + 1, map) then
               dir = 0
               dest = -2
            end
         end
         if dest == -2 then
            dest = -1
         else
            dir, dest = next_dir(dir, tx, ty, end_x, end_y, map)
         end
      end
   end

   return success
end

---
--- dungeon algorithms
---

local function maybe_dig_room(kind, min_size, max_size, rooms, map)
   if #rooms > 30 then
      return false
   end

   return Dungeon.dig_room(kind, min_size, max_size, rooms, {}, map)
end

function Dungeon.gen_type_1(map, rooms, params)
   if not maybe_dig_room(1, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for upstairs"
   end

   Dungeon.place_stairs_up(rooms[#rooms], nil, nil, map)

   if not maybe_dig_room(1, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for downstairs"
   end

   Dungeon.place_stairs_down(rooms[#rooms], nil, nil, map)

   for i=1, params.room_count do
      maybe_dig_room(1, params.min_size, params.max_size, rooms, map)
   end

   if not Dungeon.connect_rooms(rooms, true, params, map) then
      return nil, "could not connect rooms"
   end

   return map
end

-- Large room/tunnel in middle, with rooms on outer extremities
function Dungeon.gen_type_4(map, rooms, params)
   params.min_size = 8
   local n = params.min_size - 1

   map:clear("elona_sys.mapgen_wall")

   for _, x, y in Pos.iter_rect(0, 0, map:width() - 1, map:height() - 1) do
      if x > n and y > n and x + 1 < map:width() - n and y + 1 < map:height() - n then
         Map.set_tile(x, y, "elona_sys.mapgen_tunnel", map)
      end
   end

   if not maybe_dig_room(2, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for upstairs"
   end

   Dungeon.place_stairs_up(rooms[#rooms], nil, nil, map)

   if not maybe_dig_room(2, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for downstairs"
   end

   Dungeon.place_stairs_down(rooms[#rooms], nil, nil, map)

   for i=1, params.room_count do
      maybe_dig_room(2, params.min_size, params.max_size, rooms, map)
   end

   if Rand.one_in(2) then
      for i=1, math.floor(params.room_count / 4) + 1 do
         maybe_dig_room(3, params.min_size, params.max_size, rooms, map)
      end
   else
      -- fill in the center, creating a ring
      local n = params.min_size + 1 + Rand.rnd(3)
      for j=0, map:height() - n * 2 - 1 do
         local y = n + j
         for i=0, map:width() - n * 2 - 1 do
            local x = n + i
            Map.set_tile(x, y, "elona_sys.mapgen_wall", map)
         end
      end
   end

   return map
end

function Dungeon.gen_type_5(map, rooms, params)
   map = InstancedMap:new(48 + Rand.rnd(20), 22)
   map.max_crowd_density = math.floor(map:width() * map:height() / 20)
   return Dungeon.gen_type_4(map, rooms, params)
end

return Dungeon
