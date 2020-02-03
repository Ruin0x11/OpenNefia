local Chara = require("api.Chara")
local MapArea = require("api.MapArea")
local Rand = require("api.Rand")
local Log = require("api.Log")

local function center(map, chara)
   assert(class.is_an("api.InstancedMap", map))
   local x = math.floor(map:width() / 2)
   local y = math.floor(map:height() / 2)

   return x, y
end

data:add(
   {
      _id = "center",
      _type = "base.map_entrance",

      pos = center
   }
)

local function east(map, chara)
   local x = map:width() - 2
   local y = math.floor(map:height() / 2)

   return x, y
end

data:add(
   {
      _id = "east",
      _type = "base.map_entrance",

      pos = east
   }
)

local function west(map, chara)
   local x = 1
   local y = math.floor(map:height() / 2)

   return x, y
end

data:add(
   {
      _id = "west",
      _type = "base.map_entrance",

      pos = west
   }
)

local function south(map, chara)
   local x = math.floor(map:width() / 2)
   local y = map:height() - 2

   return x, y
end

data:add(
   {
      _id = "south",
      _type = "base.map_entrance",

      pos = south
   }
)

local function north(map, chara)
   local x = math.floor(map:width() / 2)
   local y = 1

   return x, y
end

data:add(
   {
      _id = "north",
      _type = "base.map_entrance",

      pos = north
   }
)

local function edge(map, chara)
   local pos = save.base.player_pos_on_map_leave
   if pos then
      return pos.x, pos.y
   end
   local next_dir = Chara.player().direction
   local x = 0
   local y = 0

   if next_dir == "West" then
      return east(map, chara)
   elseif next_dir == "East" then
      return west(map, chara)
   elseif next_dir == "North" then
      return south(map, chara)
   elseif next_dir == "South" then
      return north(map, chara)
   end

   return x, y
end

data:add(
   {
      _id = "edge",
      _type = "base.map_entrance",

      pos = edge
   }
)

local function world(map, chara, prev)
   local x, y
   local entrance = MapArea.find_entrance_in_outer_map(prev, map)
   if entrance == nil then
      Log.warn("No entrance in world map for " .. map.uid)
      x = math.floor(map:width() / 2)
      y = math.floor(map:height() / 2)
   else
      x = entrance.x
      y = entrance.y
   end

   local index = 0
   for i, c in Chara.iter_allies() do
      if c.uid == chara.uid then
         index = i
         break
      end
   end

   return x + Rand.rnd(math.floor(index / 5) + 1), y + Rand.rnd(math.floor(index / 5) + 1)
end

data:add(
   {
      _id = "world",
      _type = "base.map_entrance",

      pos = world
   }
)
