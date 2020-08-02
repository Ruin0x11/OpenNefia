local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Log = require("api.Log")
local Area = require("api.Area")

local MapEntrance = {}

function MapEntrance.center(map, chara)
   assert(class.is_an("api.InstancedMap", map))
   local x = math.floor(map:width() / 2)
   local y = math.floor(map:height() / 2)

   return { x = x, y = y }
end

function MapEntrance.east(map, chara)
   local x = map:width() - 2
   local y = math.floor(map:height() / 2)

   return { x = x, y = y }
end

function MapEntrance.west(map, chara)
   local x = 1
   local y = math.floor(map:height() / 2)

   return { x = x, y = y }
end

function MapEntrance.south(map, chara)
   local x = math.floor(map:width() / 2)
   local y = map:height() - 2

   return { x = x, y = y }
end

function MapEntrance.north(map, chara)
   local x = math.floor(map:width() / 2)
   local y = 1

   return { x = x, y = y }
end

function MapEntrance.edge(map, chara)
   local pos = save.base.player_pos_on_map_leave
   if pos then
      return pos
   end
   local next_dir = Chara.player().direction
   local x = 0
   local y = 0

   if next_dir == "West" then
      return MapEntrance.east(map, chara)
   elseif next_dir == "East" then
      return MapEntrance.west(map, chara)
   elseif next_dir == "North" then
      return MapEntrance.south(map, chara)
   elseif next_dir == "South" then
      return MapEntrance.north(map, chara)
   end

   return { x = x, y = y }
end

function MapEntrance.stairs_up(map, chara, prev)
   local prev_area = Area.for_map(prev)
   local this_floor = Area.floor_number(prev)
   local search = function(f)
      return f._id == "elona.stairs_up"
         and f.params.area_uid == prev_area.uid
         and f.params.area_floor == this_floor
   end

   -- TODO allow specifying a tag for which stairs to start on, instead of
   -- whichever one is first
   local feat = map:iter_feats():filter(search):nth(1)
   if not feat then
      Log.warn("No stairs up on were found in map.")
      return MapEntrance.center(map, chara, prev)
   end

   return { x = feat.x, y = feat.y }
end

function MapEntrance.stairs_down(map, chara, prev)
   local prev_area = Area.for_map(prev)
   local this_floor = Area.floor_number(prev)
   local search = function(f)
      return f._id == "elona.stairs_down"
         and f.params.area_uid == prev_area.uid
         and f.params.area_floor == this_floor
   end

   -- TODO allow specifying a tag for which stairs to start on, instead of
   -- whichever one is first
   local feat = map:iter_feats():filter(search):nth(1)
   if not feat then
      Log.warn("No stairs down were found in map.")
      return MapEntrance.center(map, chara, prev)
   end

   return { x = feat.x, y = feat.y }
end

return MapEntrance
