local Enum = require("api.Enum")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Charagen = require("mod.elona.api.Charagen")
local Feat = require("api.Feat")
local Area = require("api.Area")
local Map = require("api.Map")
local InstancedArea = require("api.InstancedArea")
local Log = require("api.Log")

local util = {}

function util.generate_122(elona122_map_id)
   return function()
      return Elona122Map.generate(elona122_map_id)
   end
end

function util.reload_122_map_geometry(current, elona122_map_id)
   -- >>>>>>>> shade2/map_func.hsp:255 	if cmapData@(0,cnt)=0:continue ...
   local temp = Elona122Map.generate(elona122_map_id)
   assert(current:width() == temp:width())
   assert(current:height() == temp:height())

   for _, x, y, tile in temp:iter_tiles() do
      current:set_tile(x, y, tile)
   end
   -- <<<<<<<< shade2/map_func.hsp:263 		}  ..
end

function util.chara_filter_town(callback)
   return function(map)
      -- >>>>>>>> shade2/map.hsp:9 	if (mType=mTypeTown)or(mType=mTypeVillage){ ..
      local level = Calc.calc_object_level(10, map)
      local quality = Calc.calc_object_quality(Enum.Quality.Normal)
      local filter = {
         level = level,
         quality = quality,
         fltselect = Enum.FltSelect.Town
      }

      if callback == nil then
         return filter
      end

      local result = callback(map)
      if result ~= nil and type(result) == "table" then
         return table.merge(filter, result)
      end

      return filter
      -- <<<<<<<< shade2/map.hsp:29 		} ..
   end
end

--- Fixes up stairs in maps converted from 1.22's format.
function util.connect_existing_stairs(map, area, floor)
   class.assert_is_an(InstancedArea, area)

   local is_stair = function(f)
      return f._id == "elona.stairs_up" or f._id == "elona.stairs_down"
   end

   for _, f in Feat.iter(map):filter(is_stair) do
      local delta = (f._id == "elona.stairs_up") and -1 or 1
      local next_floor = floor + delta
      local area_uid = area.uid
      if next_floor <= 0 then
         local parent = assert(Area.for_map(Map.current()))
         area_uid = parent.uid
         next_floor = parent:starting_floor()
      end

      f.params.area_uid = area_uid
      f.params.area_floor = next_floor
   end
end

function util.connect_stair_at(map, x, y, area, floor, prev_x, prev_y)
   class.assert_is_an(InstancedArea, area)

   local is_stair = function(f)
      return f._id == "elona.stairs_up" or f._id == "elona.stairs_down"
   end

   local stair = Feat.iter(map):filter(is_stair):nth(1)

   assert(Feat.is_alive(stair, map), ("Stairs not found at %d, %d"):format(x, y))

   if stair.params.area_uid == nil then
      Log.info("Connecting stair %s in 1.22 map to area %d.", stair, area.uid)
      local area_uid = area.uid
      stair.params.area_uid = area_uid
      stair.params.area_floor = floor
      stair.params.area_starting_x = prev_x or nil
      stair.params.area_starting_y = prev_y or nil
   end
end

function util.connect_stair_at_to_prev_map(map, x, y, prev_map, prev_x, prev_y)
   local prev_area = Area.for_map(prev_map)
   if prev_area then
      local prev_floor = assert(prev_area:floor_of_map(prev_map.uid))
      util.connect_stair_at(map, x, y, prev_area, prev_floor, prev_x, prev_y)
   else
      Log.error("Previous map did not have an area, so the stairs will not be connected.")
   end
end

return util
