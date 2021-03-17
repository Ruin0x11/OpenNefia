local Enum = require("api.Enum")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Charagen = require("mod.elona.api.Charagen")
local Feat = require("api.Feat")
local Area = require("api.Area")
local Map = require("api.Map")

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

return util
