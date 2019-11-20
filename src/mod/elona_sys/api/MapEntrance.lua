local Chara = require("api.Chara")
local MapArea = require("api.MapArea")
local Rand = require("api.Rand")
local Feat = require("api.Feat")
local Log = require("api.Log")

local MapEntrance = {}

function MapEntrance.center(chara, map)
   local x = math.floor(map:width() / 2)
   local y = math.floor(map:height() / 2)

   return x, y
end
function MapEntrance.east(chara, map)
   local x = map:width() - 2
   local y = math.floor(map:height() / 2)

   return x, y
end
function MapEntrance.west(chara, map)
   local x = 1
   local y = math.floor(map:height() / 2)

   return x, y
end
function MapEntrance.south(chara, map)
   local x = math.floor(map:width() / 2)
   local y = map:height() - 2

   return x, y
end
function MapEntrance.north(chara, map)
   local x = math.floor(map:width() / 2)
   local y = 1

   return x, y
end
function MapEntrance.directional(chara, map)
   local pos = save.base.player_pos_on_map_leave
   if pos then
      return pos.x, pos.y
   end
   local next_dir = Chara.player().last_move_direction
   local x = 0
   local y = 0

   if next_dir == "West" then
      return MapEntrance.east(chara, map)
   elseif next_dir == "East" then
      return MapEntrance.west(chara, map)
   elseif next_dir == "North" then
      return MapEntrance.south(chara, map)
   elseif next_dir == "South" then
      return MapEntrance.north(chara, map)
   end

   return x, y
end
function MapEntrance.world_map(chara, map, prev)
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
function MapEntrance.stair(chara, map, prev, stair)
   -- TODO: bad, stairs should indicate ignoring player_start_pos
   -- entirely since a map can have a player_start_pos and multiple
   -- stairs at the same time.
   local x, y = chara.x, chara.y
   local search
   if stair._id == "elona.stairs_up" then
      search = function(f) return f._id == "elona.stairs_down" end
   elseif stair._id == "elona.stairs_down" then
      search = function(f) return f._id == "elona.stairs_up" end
   else
      Log.warn("Map enters on stairs, but no stairs were used to enter the map.")
      search = function(f) return f._id == "elona.stairs_up" or f._id == "elona.stairs_down" end
   end

   local feat = map:iter_feats():filter(search):nth(1)
   if not feat then
      Log.warn("No stairs to enter on were found in map.")
      return MapEntrance.center(chara, map, prev)
   end

   return feat.x, feat.y
end

return MapEntrance
