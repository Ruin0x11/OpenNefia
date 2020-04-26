--- Functions dealing with the connections between maps.
--- @module MapArea

local Feat = require("api.Feat")
local Log = require("api.Log")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")
local data = require("internal.data")
local save = require("internal.global.save")

local MapArea = {}

-- TODO: do not use an implicit Map.current() in any function, since
-- this API is not used as often.

--- Returns true if this feat acts as an entrace to another map.
---
--- @tparam IFeat feat
--- @treturn bool
function MapArea.is_entrance(feat)
   return false
end

function MapArea.current()
   return save.base.area_mapping:area_for_map(Map.current())
end

function MapArea.area_for_map(map_or_uid)
   return save.base.area_mapping:area_for_map(map_or_uid)
end

function MapArea.create_area(outer_map_or_uid, x, y)
   return save.base.area_mapping:create_area(outer_map_or_uid, x, y)
end

function MapArea.add_map_to_area(area_uid, map_or_uid)
   return save.base.area_mapping:add_map_to_area(area_uid, map_or_uid)
end

function MapArea.iter_map_entrances(kind, map)
   return nil
end

--- Given an inner map, finds an entrance leading to it that is
--- contained in an outer map (which defaults to the current map)
---
--- @tparam InstancedMap|uid:InstancedMap inner_map_or_uid
--- @tparam[opt] InstancedMap outer_map Defaults to the current map.
--- @treturn[opt] IFeat
function MapArea.find_entrance_in_outer_map(inner_map_or_uid, outer_map)
   outer_map = outer_map or Map.current()

   local inner_uid = inner_map_or_uid
   if type(inner_map_or_uid) == "table" then
      class.assert_is_an(InstancedMap, inner_map_or_uid)
      inner_uid = inner_map_or_uid.uid
   end

   local pred = function(feat)
      return feat.map_uid == inner_uid
   end

   local entrance = outer_map:iter_feats():filter(pred):nth(1)

   if not entrance then
      Log.warn("Outer map %d missing entrance for inner map %d", outer_map.uid, inner_uid)
   end

   return entrance
end

--- Given an inner map, loads its outer map.
---
--- @treturn bool success
--- @treturn {map=InstancedMap,start_x=int,start_y=int}|string result/error
function MapArea.load_outer_map(inner_map)
   return nil, "error"
end

--- Given a feat that acts like a map entrance, loads its inner map.
--- It will be generated if necessary.
---
--- @tparam IFeat feat
--- @tparam bool associate If true, associates the inner map with the feat's map
--- @treturn bool success
--- @treturn InstancedMap|string result/error
--- @treturn bool true if map was generated for the first time
function MapArea.load_map_of_entrance(feat, associate)
   local map = nil
   map:emit("base.on_map_loaded_from_entrance", {entrance=feat})
   return map
end

return MapArea
