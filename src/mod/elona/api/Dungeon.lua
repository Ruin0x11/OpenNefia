local Item = require("api.Item")
local Enum = require("api.Enum")
local Feat = require("api.Feat")
local Pos = require("api.Pos")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")
local Rand = require("api.Rand")
local Charagen = require("mod.elona.api.Charagen")
local Itemgen = require("mod.elona.api.Itemgen")
local Calc = require("mod.elona.api.Calc")
local I18N = require("api.I18N")

-- functions for nefia generation used by Elona 1.22's map generators.
local Dungeon = {}

Dungeon.RoomType = {
   Anywhere = 0,
   NonEdge = 1,
   Edge = 2,
   Small = 3,
   Random = 4,
}

Dungeon.WallType = {
   None = 0,
   Wall = 1,
   Floor = 2,
   Room = 3
}

Dungeon.DoorType = {
   None = 0,
   Room = 1,
   Random = 2,
   RandomNoDoor = 3,
}

-- >>>>>>>> shade2/init.hsp:275 	#define global DOWN 		0 ..
Dungeon.Direction = {
   Down = 0,
   Left = 1,
   Right = 2,
   Up = 3
}
-- <<<<<<<< shade2/init.hsp:278 	#define global UP		3 ...

local room_kinds = {
   [Dungeon.RoomType.Anywhere] = {
      pos = Dungeon.RoomType.Anywhere,
      wall = Dungeon.WallType.None,
      door = Dungeon.DoorType.None
   },
   [Dungeon.RoomType.NonEdge] = {
      pos = Dungeon.RoomType.NonEdge,
      wall = Dungeon.WallType.Wall,
      door = Dungeon.DoorType.None
   },
   [Dungeon.RoomType.Edge] = {
      pos = Dungeon.RoomType.Edge,
      wall = Dungeon.WallType.Wall,
      door = Dungeon.DoorType.Room
   },
   [Dungeon.RoomType.Small] = {
      pos = Dungeon.RoomType.Small,
      wall = Dungeon.WallType.Floor,
      door = Dungeon.DoorType.Random2
   },
   [Dungeon.RoomType.Random] = {
      pos = Dungeon.RoomType.Random,
      wall = Dungeon.WallType.Room,
      door = Dungeon.DoorType.None
   },
}

function Dungeon.calc_door_difficulty(map)
   return Rand.rnd(math.floor(math.abs(map.level * 3 / 2)) + 1)
end

function Dungeon.default_chara_filter(dungeon)
   -- >>>>>>>> shade2/map.hsp:89 	if mType>=headDungeon{ ..
   return {
      level = Calc.calc_object_level(dungeon.level, dungeon),
      quality = Calc.calc_object_quality(Enum.Quality.Normal),
   }
   -- <<<<<<<< shade2/map.hsp:92 		} ..
end

function Dungeon.random_chara_filter(map)
   local archetype = map:archetype()
   if archetype and archetype.chara_filter then
      return archetype.chara_filter
   end

   return Dungeon.default_chara_filter
end

function Dungeon.create_map(floor, params, width, height)
   width = width or params.width
   height = height or params.height

   local map = InstancedMap:new(width, height)
   map:clear("elona.mapgen_default")
   map.level = floor
   if params.max_crowd_density then
      map.max_crowd_density = params.max_crowd_density
   end
   return map
end

function Dungeon.calc_room_size(pos, min_size, max_size, map_width, map_height)
   local x, y, w, h, dir

   if pos == Dungeon.RoomType.Anywhere then
      -- room anywhere
      w = Rand.rnd(max_size) + min_size
      h = Rand.rnd(max_size) + min_size
      x = Rand.rnd(map_width) + 2
      y = Rand.rnd(map_height) + 2
   elseif pos == Dungeon.RoomType.NonEdge then
      -- room anywhere, away from edges
      w = math.floor((Rand.rnd(max_size) + min_size) / 3 * 3) + 5
      h = math.floor((Rand.rnd(max_size) + min_size) / 3 * 3) + 5
      x = math.floor(Rand.rnd(map_width) / 3 * 3) + 2
      y = math.floor(Rand.rnd(map_height) / 3 * 3) + 2
   elseif pos == Dungeon.RoomType.Edge then
      -- room on the edge
      dir = Rand.rnd(4)
      if dir == Dungeon.Direction.Up or dir == Dungeon.Direction.Down then
         x = Rand.rnd(math.floor(map_width - min_size * 3 / 2 - 2)) + math.floor(min_size / 2)
         w = Rand.rnd(min_size) + math.floor(min_size / 2) + 3
         h = min_size
         if dir == Dungeon.Direction.Up then
            y = 0
         else
            y = map_height - h
         end
      else
         y = Rand.rnd(math.floor(map_height - min_size * 3 / 2 - 2)) + math.floor(min_size / 2)
         w = min_size
         h = Rand.rnd(min_size) + math.floor(min_size / 2) + 3
         if dir == Dungeon.Direction.Left then
            x = 0
         else
            x = map_width - w
         end
      end
   elseif pos == Dungeon.RoomType.Small then
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
   elseif pos == Dungeon.RoomType.Random then
      w = Rand.rnd(max_size) + min_size
      h = Rand.rnd(max_size) + min_size
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

   for _ = 1, 100 do
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

         if pos == Dungeon.RoomType.NonEdge then
            if mx >= map_width + 1 or my >= map_height + 1 then
               break
            end
         end

         if pos == Dungeon.RoomType.Small then
            if Map.tile(mx, my, map)._id ~= "elona.mapgen_room" then
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

local ROOM_ITEMS = { "elona.cabinet", "elona.neat_bar_table", "elona.pachisuro_machine", "elona.green_plant" }

function Dungeon.dig_room(kind, min_size, max_size, rooms, params, map)
   -- >>>>>>>> shade2/map_func.hsp:616  ..
   local base = room_kinds[kind or Dungeon.RoomType.Anywhere]
   params = table.merge_missing(params, base)

   local room = Dungeon.calc_valid_room(params.pos, min_size, max_size, rooms, map)
   if room == nil then
      return false
   end

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

         if params.wall ~= Dungeon.WallType.None then
            if i == 0 or j == 0 or i == room.width-1 or j == room.height - 1 then
               if params.wall == Dungeon.WallType.Wall then
                  tile = "wall"
               elseif params.wall == Dungeon.WallType.Floor then
                  tile = "default"
               elseif params.wall == Dungeon.WallType.Room then
                  tile = "room"
                  if tile1 == 1 and i == 0 then
                     tile = "wall"
                  end
                  if tile2 == 1 and j == 0  then
                     tile = "wall"
                     if i ~= 0 and i ~= room.width - 1 then
                        if Rand.one_in(3) then
                           local _id = Rand.choice(ROOM_ITEMS)
                           Item.create(_id, x, y + 1, {}, map)
                        elseif i % 2 == 1 then
                           Item.create("elona.candle", x, y + 1, {}, map)
                        end
                     end
                  end
                  if tile1 == 2 and i == room.width - 1 then
                     tile = "wall"
                  end
                  if tile2 == 2 and j == room.height - 1 then
                     tile = "wall"
                     if Rand.one_in(3) then
                        local _id = Rand.choice(ROOM_ITEMS)
                        Item.create(_id, x, y + 1, {}, map)
                     elseif i % 2 == 1 then
                        Item.create("elona.candle", x, y + 1, {}, map)
                     end
                  end
               end
            end
         end

         Map.set_tile(x, y, "elona.mapgen_" .. tile, map)
      end
   end

   if params.door == Dungeon.DoorType.Room then
      Dungeon.create_room_door(room, nil, true, map)
   elseif params.door == Dungeon.DoorType.Random or params.door == Dungeon.DoorType.RandomNoDoor then
      for dir=0, 3 do
         local place_door = params.door ~= Dungeon.DoorType.RandomNoDoor
         Dungeon.create_room_door(room, dir, place_door, map)
      end
   end

   return room
   -- <<<<<<<< shade2/map_func.hsp:762 	return true ..
end

function Dungeon.create_room_door(room, dir, place_door, map)
   -- >>>>>>>> shade2/map_func.hsp:577 #deffunc map_createRoomDoor ..
   dir = dir or room.dir or Dungeon.Direction.Down

   local pos

   if dir == Dungeon.Direction.Up or dir == Dungeon.Direction.Down then
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
      if dir == Dungeon.Direction.Up then
         x = pos + room.x + 1
         y = room.y + room.height - 1
         dirs1 = { 0, 0 }
         dirs2 = {-1, 1 }
      elseif dir == Dungeon.Direction.Down then
         x = pos + room.x + 1
         y = room.y
         dirs1 = { 0, 0 }
         dirs2 = {-1, 1 }
      elseif dir == Dungeon.Direction.Left then
         x = room.x + room.width - 1
         y = pos + room.y + 1
         dirs1 = {-1, 1 }
         dirs2 = { 0, 0 }
      elseif dir == Dungeon.Direction.Right then
         x = room.x
         y = pos + room.y + 1
         dirs1 = {-1, 1 }
         dirs2 = { 0, 0 }
      end

      local success = true
      for i=1, 2 do
         local dx = x + dirs1[i]
         local dy = y + dirs2[i]
         --map:set_tile(dx, dy, "elona.mapgen_room")
         --Item.create("elona.putitoro", dx, dy, {}, map)
         if dx < 0 or dy < 0 or dx >= map:width() or dy >= map:height() then
            success = false
            break
         end
         if Map.tile(dx, dy, map)._id == "elona.mapgen_wall" then
            success = false
            break
         end
      end

      if success then
         Map.set_tile(x, y, "elona.mapgen_room", map)
         if place_door then
            local difficulty = Dungeon.calc_door_difficulty(map)
            Feat.create("elona.door", x, y, {difficulty = difficulty}, map)
         end
         return true
      end
   end

   return false
   -- <<<<<<<< shade2/map_func.hsp:606 	return ..
end

function Dungeon.place_stairs_up_in_room(room, map)
   local x = Rand.rnd(room.width - 2) + room.x + 1
   local y = Rand.rnd(room.height - 2) + room.y + 1
   room.has_stairs_up = true

   return Feat.create("elona.stairs_up", x, y, {}, map)
end

function Dungeon.place_stairs_down_in_room(room, map)
   local x = Rand.rnd(room.width - 2) + room.x + 1
   local y = Rand.rnd(room.height - 2) + room.y + 1
   room.has_stairs_down = true

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
      elseif dir == "North" then
         x = room.x + Rand.rnd(room.width - 2) + 1
         y = room.y
      elseif dir == "South" then
         x = room.x + Rand.rnd(room.width - 2) + 1
         y = room.y + room.height - 1
      end

      if dx ~= 0 then
         if Map.tile(x, y - 1, map)._id == "elona.mapgen_room" or Map.tile(x, y + 1, map)._id == "elona.mapgen_room" then
            found = false
         end
      end
      if dy ~= 0 then
         if Map.tile(x - 1, y, map)._id == "elona.mapgen_room" or Map.tile(x + 1, y, map)._id == "elona.mapgen_room" then
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
      for i = 1, Rand.rnd(params.room_entrance_count + 1) + 1 do
         local start_x, start_y, end_x, end_y

         for j = room_idx, room_idx + 1 do
            local room = rooms[j]
            local x, y, dx, dy = calc_room_entrance(room, map)

            Map.set_tile(x, y, "elona.mapgen_room", map)
            Map.set_tile(x + dx, y + dy, "elona.mapgen_tunnel", map)
            if j == room_idx then
               start_x = x + dx
               start_y = y + dy
            else
               end_x = x + dx
               end_y = y + dy
            end
         end

         success = success or Dungeon.dig_to_entrance(start_x, start_y, end_x, end_y, true, params.hidden_path_chance, map)
         if success then
            break
         end
      end

      if not success then
         return false
      end

      room_idx = room_idx + 1
   end

   return true
end

local function can_dig(x, y, map)
   if x < 1 or y < 1 or x > map:width() - 2 or y > map:height() - 2 then
      return false
   end

   local tile = Map.tile(x, y, map)
   if tile._id == "elona.mapgen_tunnel" then
      return true
   end

   return tile._id == "elona.mapgen_default"
end

local function next_dir(dir, tx, ty, end_x, end_y, map)
   local dest

   if tx >= end_x - 4 and tx <= end_x + 4 and ty >= end_y - 4 and tx <= end_y + 4 then
      if tx < end_x then
         dir = Dungeon.Direction.Right
         if ty > end_y then
            dest = Dungeon.Direction.Up
         else
            dest = Dungeon.Direction.Down
         end
      end
      if tx > end_x then
         dir = Dungeon.Direction.Left
         if ty > end_y then
            dest = Dungeon.Direction.Up
         else
            dest = Dungeon.Direction.Down
         end
      end
      if ty < end_y then
         dir = Dungeon.Direction.Down
         if tx > end_x then
            dest = Dungeon.Direction.Left
         else
            dest = Dungeon.Direction.Right
         end
      end
      if ty > end_y then
         dir = Dungeon.Direction.Up
         if tx > end_x then
            dest = Dungeon.Direction.Left
         else
            dest = Dungeon.Direction.Right
         end
      end

      return dir, dest
   end

   if dir == Dungeon.Direction.Left or dir == Dungeon.Direction.Right then
      if ty > end_y then
         dir = Dungeon.Direction.Up
      else
         dir = Dungeon.Direction.Down
      end
      if tx > end_x then
         dest = Dungeon.Direction.Left
      else
         dest = Dungeon.Direction.Right
      end
   else
      if tx > end_x then
         dir = Dungeon.Direction.Left
      else
         dir = Dungeon.Direction.Right
      end
      if ty > end_y then
         dest = Dungeon.Direction.Up
      else
         dest = Dungeon.Direction.Down
      end
   end

   return dir, dest
end

local function next_dir_2(dir, last_dir, tx, ty, end_x, end_y, map)
   local function swap(do_swap)
      if do_swap then
         local temp = last_dir
         last_dir = dir
         dir = temp
      else
         dir = last_dir
         last_dir = nil
      end
   end

   if last_dir then
      if last_dir == Dungeon.Direction.Left and can_dig(tx - 1, ty, map) then
         swap(tx == end_x)
      elseif last_dir == Dungeon.Direction.Right and can_dig(tx + 1, ty, map) then
         swap(tx == end_x)
      elseif last_dir == Dungeon.Direction.Up and can_dig(tx, ty - 1, map) then
         swap(ty == end_y)
      elseif last_dir == Dungeon.Direction.Down and can_dig(tx, ty + 1, map) then
         swap(ty == end_y)
      end
   end

   if dir == Dungeon.Direction.Left or dir == Dungeon.Direction.Right then
      if tx == end_x then
         if ty > end_y and can_dig(tx, ty - 1, map) then
            last_dir = dir
            dir = Dungeon.Direction.Up
         elseif ty < end_y and can_dig(tx, ty + 1, map) then
            last_dir = dir
            dir = Dungeon.Direction.Down
         end
      end
   else
      if ty == end_y  then
         if tx > end_x and can_dig(tx - 1, ty, map) then
            last_dir = dir
            dir = Dungeon.Direction.Left
         elseif tx < end_x and can_dig(tx + 1, ty, map) then
            last_dir = dir
            dir = Dungeon.Direction.Right
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

      if dir == Dungeon.Direction.Left then
         dx = tx - 1
      elseif dir == Dungeon.Direction.Right then
         dx = tx + 1
      elseif dir == Dungeon.Direction.Up then
         dy = ty - 1
      elseif dir == Dungeon.Direction.Down then
         dy = ty + 1
      end

      if can_dig(dx, dy, map) then
         tx = dx
         ty = dy
         Map.set_tile(dx, dy, "elona.mapgen_tunnel", map)
         if Rand.rnd(200) < hidden_path_chance then
            Map.set_tile(dx, dy, "elona.mapgen_fog", map)
            Feat.create("elona.hidden_path", dx, dy, {force=true}, map)
         end
         -- if not straight and Rand.one_in(4) then
         --    dir, dest = next_dir(dir, tx, ty, end_x, end_y, map)
         -- end
      else
         if dest == Dungeon.Direction.Left then
            if can_dig(tx - 1, ty, map) then
               dir = Dungeon.Direction.Left
               dest = -2
            end
         elseif dest == Dungeon.Direction.Right then
            if can_dig(tx + 1, ty, map) then
               dir = Dungeon.Direction.Right
               dest = -2
            end
         elseif dest == Dungeon.Direction.Up then
            if can_dig(tx, ty - 1, map) then
               dir = Dungeon.Direction.Up
               dest = -2
            end
         elseif dest == Dungeon.Direction.Down then
            if can_dig(tx, ty + 1, map) then
               dir = Dungeon.Direction.Down
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

-- BUG: is not always fully connected, leading to "pockets"
function Dungeon.dig_maze(map, rooms, params, class, bold)
   local ind = 0
   local prev_ind = 0

   local dig_x = bold
   local dig_y = bold
   local was_dug

   local maze = {}
   maze[0] = 7

   local way = { 0, 1, 2, 3 }

   while true do
      way = Rand.shuffle(way)

      was_dug = false

      local try_dig = function(dir)
         prev_ind = ind

         if dir == Dungeon.Direction.Down then
            if math.floor(prev_ind / class) == 0 then
               return false
            else
               ind = ind - class
            end
         elseif dir == Dungeon.Direction.Left then
            if prev_ind % class == class - 1 then
               return false
            else
               ind = ind + 1
            end
         elseif dir == Dungeon.Direction.Right then
            if math.floor(prev_ind / class) == class - 1 then
               return false
            else
               ind = ind + class
            end
         elseif dir == Dungeon.Direction.Up then
            if prev_ind % class == 0 then
               return false
            else
               ind = ind - 1
            end
         end

         if maze[ind] ~= nil then
            ind = prev_ind
            return false
         end

         dig_x = (prev_ind % class) * bold * 2 + bold
         dig_y = math.floor(prev_ind / class) * bold * 2 + bold

         local function dig(w, h)
            for j = 0, h - 1 do
               local y = dig_y - bold * 2 + j - bold + 4
               for i = 0, w - 1 do
                  local x = dig_x + i - bold + 4
                  map:set_tile(x, y, "elona.mapgen_tunnel")
               end
            end
         end

         if dir == 0 then
            maze[ind] = 3
            dig(bold - 1, bold * 2)
         elseif dir == 1 then
            maze[ind] = 4
            dig(bold * 3 - 1, bold - 1)
         elseif dir == 2 then
            maze[ind] = 1
            dig(bold - 1, bold * 3 - 1)
         elseif dir == 3 then
            maze[ind] = 2
            dig(bold * 2, bold - 1)
         end

         return true
      end

      for _, dir in ipairs(way) do
         if try_dig(dir) then
            was_dug = true
            break
         end
      end

      if not was_dug then
         if maze[ind] == 7 then
            break
         end
         if  maze[ind] == 1 then
            ind = ind - class
         elseif maze[ind] == 2 then
            ind = ind + 1
         elseif maze[ind] == 3 then
            ind = ind + class
         elseif maze[ind] == 4 then
            ind = ind - 1
         end
      end
   end
end

function Dungeon.place_stairs_in_maze(map)
   local up_x, up_y, down_x, down_y

   for _ = 0, 1000 do
      up_x = Rand.rnd(map:width())
      up_y = Rand.rnd(map:height())
      if map:tile(up_x, up_y)._id == "elona.mapgen_tunnel" then
         down_x = Rand.rnd(map:width())
         down_y = Rand.rnd(map:height())
         if map:tile(down_x, down_y)._id == "elona.mapgen_tunnel" then
            if Pos.dist(up_x, up_y, down_x, down_y) >= 10 then
               break
            end
         end
      end
   end

   Feat.create("elona.stairs_up", up_x, up_y, {}, map)
   Feat.create("elona.stairs_down", down_x, down_y, {}, map)
end

local function maybe_dig_room(kind, min_size, max_size, rooms, map)
   if #rooms > 30 then
      return false
   end

   return Dungeon.dig_room(kind, min_size, max_size, rooms, {}, map)
end

---
--- dungeon algorithms
---

--- Rooms connected by tunnels.
function Dungeon.gen_type_standard(floor, params)
   local map = Dungeon.create_map(floor, params)

   local rooms = {}

   if not maybe_dig_room(1, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for upstairs"
   end

   Dungeon.place_stairs_up_in_room(rooms[#rooms], map)

   if not maybe_dig_room(1, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for downstairs"
   end

   Dungeon.place_stairs_down_in_room(rooms[#rooms], map)

   for i=1, params.room_count do
      maybe_dig_room(1, params.min_size, params.max_size, rooms, map)
   end

   if not Dungeon.connect_rooms(rooms, true, params, map) then
      return nil, "could not connect rooms"
   end

   map.rooms = rooms

   return map
end

function Dungeon.gen_type_wide(floor, params)
   local map = Dungeon.create_map(floor, params)
   params.max_size = 3

   local rooms = {}

   local x = math.floor(map:width() / 2)
   local y = math.floor(map:height() / 2)

   map:set_tile(x, y, "elona.mapgen_room")

   local chance = 2
   local dir = 0

   for _ = 1, params.tunnel_length do
      if Rand.one_in(chance) then
         dir = Rand.rnd(4)
      end

      if dir == Dungeon.Direction.Right then
         x = x + 1
         if x > map:width() - 2 then
            dir = 0
            x = map:width() - 2
         end
      end
      if dir == Dungeon.Direction.Left then
         x = x - 1
         if x < 1 then
            dir = 3
            x = 1
         end
      end
      if dir == Dungeon.Direction.Down then
         y = y + 1
         if y > map:height() - 2 then
            dir = 1
            y = map:height() - 2
         end
      end
      if dir == Dungeon.Direction.Up then
         y = y - 1
         if y < 1 then
            dir = 2
            y = 1
         end
      end

      map:set_tile(x, y, "elona.mapgen_room")
   end

   if not maybe_dig_room(0, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for upstairs"
   end

   Dungeon.place_stairs_up_in_room(rooms[#rooms], map)

   if not maybe_dig_room(0, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for downstairs"
   end

   Dungeon.place_stairs_down_in_room(rooms[#rooms], map)

   for _=1, params.room_count do
      maybe_dig_room(0, params.min_size, params.max_size, rooms, map)
   end

   for _=1, params.extra_room_count do
      local x, y, dx, dy, room_x, room_y
      local found = false
      for _ = 0, 100 do
         x = Rand.rnd(map:width())
         y = Rand.rnd(map:height())
         if map:tile(x, y)._id == "elona.mapgen_room" then
            dx = Rand.rnd(params.max_size) + params.min_size
            dy = Rand.rnd(params.max_size) + params.min_size
            room_x = Rand.rnd(dx)
            room_y = Rand.rnd(dy)
            if x > 1 and y > 1 and x + dx < map:width() - 2 and y + dy < map:height() - 2 then
               found = true
            end
         end
      end

      if found then
         dy = y
         for _ = 1, room_y do
            dx = x
            for _ = 1, room_x do
               map:set_tile(dx, dy, "elona.mapgen_room")
               dx = dx + 1
            end
            dy = dy + 1
         end
      end
   end

   map.rooms = rooms

   return map
end

--- One large room spanning the entire map.
function Dungeon.gen_type_big_room(floor, params)
   local width = (48 + Rand.rnd(20))
   local height = 22
   local map = Dungeon.create_map(floor, params, width, height)
   map.max_crowd_density = width * height / 20

   for _, x, y in map:iter_tiles() do
      local is_border = x == 0 or y == 0 or x + 1 == map:width() or y + 1 == map:height()
      if not is_border then
         map:set_tile(x, y, "elona.mapgen_room")
      end
   end

   local up_x = Rand.rnd(map:width() / 2) + 2
   local up_y = Rand.rnd(map:height() - 4) + 2

   local down_x = Rand.rnd(map:width() / 2) + math.floor(map:width() / 2) - 2
   local down_y = Rand.rnd(map:height() - 4) + 2

   if Rand.one_in(2) then
      -- Swap the X positions.
      local temp = up_x
      up_x = down_x
      down_x = temp
   end

   Feat.create("elona.stairs_up", up_x, up_y, {}, map)
   Feat.create("elona.stairs_down", down_x, down_y, {}, map)

   return map
end

-- Large room/tunnel in middle, with rooms on outer extremities
function Dungeon.gen_type_resident(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:417 *map_createDungeonResident ..
   local map = Dungeon.create_map(floor, params)
   params.min_size = 8

   local rooms = {}

   local n = params.min_size - 1

   for _, x, y in map:iter_tiles() do
      Map.set_tile(x, y, "elona.mapgen_wall", map)
      if x > n and y > n and x + 1 < map:width() - n and y + 1 < map:height() - n then
         Map.set_tile(x, y, "elona.mapgen_tunnel", map)
      end
   end

   if not maybe_dig_room(2, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for upstairs"
   end

   Dungeon.place_stairs_up_in_room(rooms[#rooms], map)

   if not maybe_dig_room(2, params.min_size, params.max_size, rooms, map) then
      return nil, "could not place room for downstairs"
   end

   Dungeon.place_stairs_down_in_room(rooms[#rooms], map)

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
            Map.set_tile(x, y, "elona.mapgen_wall", map)
         end
      end
   end

   map.rooms = rooms

   return map
   -- <<<<<<<< shade2/map_rand.hsp:456 	return true ..
end

-- Same as type 4 but wider.
function Dungeon.gen_type_jail(floor, params)
   params.width = 48 + Rand.rnd(20)
   params.height = 22

   local map, err = Dungeon.gen_type_resident(floor, params)
   if map == nil then
      return nil
   end

   map.max_crowd_density = math.floor(map:width() * map:height() / 20)

   return map
end

-- Maps used in hunting quests.
function Dungeon.gen_type_hunt(floor, params)
   -- >>>>>>>> shade2/map_rand.hsp:305 *map_createDungeonHunt ..
   local map = Dungeon.create_map(floor, params)
   map.is_indoor = false
   map:clear("elona.mapgen_room")

   for _ = 1, Rand.rnd(map:width() * map:height() / 30) do
      local x = Rand.rnd(map:width())
      local y = Rand.rnd(map:height())
      map:set_tile(x, y, "elona.mapgen_wall")
   end

   if params.outer_map_id == "elona.noyel" then
      map.tileset = "elona.noyel_fields"
   end

   local chara_filter = params.chara_filter or Dungeon.random_chara_filter(map)

   map.max_crowd_density = 0
   for _=1, 10 + Rand.rnd(6) do
      local chara = Charagen.create(nil, nil, chara_filter(map), map)
      if chara then
         chara.relation = Enum.Relation.Enemy
      end
   end

   for _=1, 10 + Rand.rnd(6) do
      local item = Itemgen.create(nil, nil,
                                  {categories = {"elona.tree"}},
                                  map)
      if item then
         item.own_state = Enum.OwnState.NotOwned
      end
   end

   return map
   -- <<<<<<<< shade2/map_rand.hsp:331 	return true ..
end

-- Long vertical tunnel.
function Dungeon.gen_type_long(floor, params)
   local width = 30
   local height = (60 + Rand.rnd(60))
   local map = Dungeon.create_map(floor, params, width, height)
   map.max_crowd_density = width * height / 20

   local tunnel_width = 6
   local dx = math.floor(map:width() / 2) - math.floor(tunnel_width / 2)
   local variance = 0

   for i = 1, map:height() - 4 do
      local y = i + 1
      for j = 1, tunnel_width do
         local x = j - 1 + dx
         map:set_tile(x, y, "elona.mapgen_tunnel")
      end
      if variance <= 0 and Rand.one_in(2) then
         variance = Rand.rnd(12)
      end
      if Rand.one_in(2) and tunnel_width > 4 then
         tunnel_width = tunnel_width - Rand.rnd(2)
      end
      if variance > 0 then
         if variance < 5 and width > 3 then
            tunnel_width = tunnel_width - Rand.rnd(2)
            variance = variance - 1
         end
         if variance > 4 and width < 10 then
            tunnel_width = tunnel_width + 1
            variance = variance - 1
         end
      end
      if dx > 1 then
         dx = dx - Rand.rnd(2)
      end
      if dx + tunnel_width < map:width() - 1 then
         dx = dx + Rand.rnd(2)
      end
      if dx + tunnel_width > map:width() then
         tunnel_width = map:width() - dx
      end
   end

   while true do
      local x = Rand.rnd(map:width())
      local y = Rand.rnd(15)
      if map:tile(x, y)._id == "elona.mapgen_tunnel" then
         Feat.create("elona.stairs_up", x, y, {}, map)
         break
      end
   end

   while true do
      local x = Rand.rnd(map:width())
      local y = map:height() - Rand.rnd(15) - 1
      if map:tile(x, y)._id == "elona.mapgen_tunnel" then
         Feat.create("elona.stairs_down", x, y, {}, map)
         break
      end
   end

   return map
end

-- Maze with corridors of width 4 (Minotaur's Nest).
function Dungeon.gen_type_maze(floor, params)
   local class = 12
   local bold = 2

   local width = (class * (bold * 2) - bold + 8)
   local height = params.width
   local map = Dungeon.create_map(floor, params, width, height)
   map.max_crowd_density = width * height / 12

   local rooms = {}

   Dungeon.dig_maze(map, rooms, params, class, bold)
   Dungeon.place_stairs_in_maze(map)
   Dungeon.dig_maze(map, rooms, params, class, bold)

   map.rooms = rooms

   return map
end

-- Large cavern with walls interspersed throughout (Puppy's Cave).
function Dungeon.gen_type_puppy_cave(floor, params)
   local class = 5 + Rand.rnd(4)
   local bold = 2

   local width = (class * (bold * 2) - bold + 8)
   local height = params.width
   local map = Dungeon.create_map(floor, params, width, height)
   map.max_crowd_density = width * height / 12

   local rooms = {}

   Dungeon.dig_maze(map, rooms, params, class, bold)
   Dungeon.place_stairs_in_maze(map)

   local tunnels = {}

   for cnt = 1, 50 do
      local tunnel = 100 + cnt + 1
      local x, y

      local found = false
      for try = 1, 1000 do
         x = Rand.rnd(map:width())
         y = Rand.rnd(map:height())
         if map:tile(x, y)._id == "elona.mapgen_tunnel" then
            found = true
            break
         end
      end

      if not found then
         return nil, "could not find tunnel"
      end

      local try_dig = function(dx, dy, width)
         if dx < 1 or dy < 1 or dx >= map:width() - 1 or dy >= map:height() - 1 then
            return
         end

         if Pos.dist(x, y, dx, dy) >= width / 2 then
            return
         end

         local check = function(tx, ty)
            local id = map:tile(tx, ty)._id

            local tunnel_at = tunnels[tx+ty*map:width()]

            if tunnel_at then
               if tunnel_at ~= tunnel and id ~= "elona.mapgen_default" then
                  return false
               end
            else
               if id ~= "elona.mapgen_tunnel" and id ~= "elona.mapgen_default" then
                  return false
               end
            end

            return true
         end

         if not check(dx - 1, dy    ) then return end
         if not check(dx + 1, dy    ) then return end
         if not check(dx,     dy - 1) then return end
         if not check(dx,     dy + 1) then return end
         if not check(dx - 1, dy - 1) then return end
         if not check(dx + 1, dy - 1) then return end
         if not check(dx - 1, dy + 1) then return end
         if not check(dx + 1, dy + 1) then return end

         map:set_tile(dx, dy, "elona.mapgen_tunnel")
         tunnels[dx+dy*map:width()] = tunnel
      end

      local width = 10 + Rand.rnd(4)
      for j = 0, width - 1 do
         local dy = j + y - math.floor(width / 2)
         for i = 0, width - 1 do
            local dx = i + x - math.floor(width / 2)

            try_dig(dx, dy, width)
         end
      end
   end

   local try_place_door = function(x, y)
      if map:tile(x, y)._id ~= "elona.mapgen_tunnel" then
         return
      end
      if Feat.at(x, y, map):length() > 0 then
         return
      end

      if map:tile(x - 1, y)._id == "elona.mapgen_tunnel"
         and map:tile(x + 1, y)._id == "elona.mapgen_tunnel"
      then
         if map:tile(x, y - 1)._id == "elona.mapgen_default"
            and map:tile(x, y + 1)._id == "elona.mapgen_default"
         then
            Feat.create("elona.door", x, y, {difficulty = Dungeon.calc_door_difficulty(map)}, map)
         end

         return
      end

      if map:tile(x, y - 1)._id == "elona.mapgen_tunnel"
         and map:tile(x, y + 1)._id == "elona.mapgen_tunnel"
      then
         if map:tile(x - 1, y)._id == "elona.mapgen_default"
            and map:tile(x + 1, y)._id == "elona.mapgen_default"
         then
            Feat.create("elona.door", x, y, {difficulty = Dungeon.calc_door_difficulty(map)}, map)
         end

         return
      end
   end

   for j = 1, math.floor(map:height() / 2) - 2 - 1 do
      local y = j * 2
      for i = 1, math.floor(map:width() / 2) - 2 - 1 do
         local x = i * 2

         try_place_door(x, y)
      end
   end

   map.rooms = rooms

   return map
end

function Dungeon.set_template_property(params, property, value)
   params.properties = params.properties or {}
   params.properties[property] = value
end

function Dungeon.map_level_text(level)
   -- >>>>>>>> shade2/text.hsp:415 	if areaType(gArea)!mTypeTown:if (areaId(gArea)=ar ...
   return I18N.get("nefia.level", level)
   -- <<<<<<<< shade2/text.hsp:417 	} ..
end

return Dungeon
