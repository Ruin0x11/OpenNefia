local InstancedMap = require("api.InstancedMap")
local InstancedArea = require("api.InstancedArea")
local field = require("game.field")
local save = require("internal.global.save")
local Log = require("api.Log")

local Area = {}

function Area.metadata(map)
   local area = Area.for_map(map or field.map)

   if area == nil then
      return nil
   end

   return area.metadata
end

local mapping

function Area.current()
   return Area.for_map(field.map)
end

function Area.floor_number(map)
   map = map or field.map
   local area = Area.for_map(map)
   if area == nil then
      return 1
   end

   local floor = area:iter_maps():filter(function(floor, m) return m.uid == map.uid end):nth(1)

   return floor
end

function Area.for_map(map_or_uid)
   local uid = map_or_uid
   if class.is_an(InstancedMap, map_or_uid) then
      uid = map_or_uid.uid
   end
   assert(type(uid) == "number", "UID must be number")

   local areas = save.base.areas

   if mapping == nil then
      local map_to_area = fun.iter(areas)
         :map(function(area) return area:iter_maps():map(function(floor, map) return map.uid, area end):to_map() end)
      mapping = {}
      for _, m in map_to_area:unwrap() do
         for map_uid, area in pairs(m) do
            mapping[map_uid] = area
         end
      end
   end

   return mapping[uid]
end

function Area.get(uid)
   assert(type(uid) == "number")

   local areas = save.base.areas

   return areas[uid] or nil
end

function Area.register(area)
   assert(class.is_an(InstancedArea, area))

   local areas = save.base.areas

   assert(areas[area.uid] == nil, "Area has already been registered")

   local Map = require("api.Map")

   Log.info("Registering area '%d' with maps: %s", area.uid, inspect(fun.iter(area.maps):extract("uid"):to_list()))

   for _, _, map in area:iter_maps() do
      assert(Map.is_saved(map.uid), ("Map '%d' must be saved before registering an area with it"):format(map.uid))
      local area_for_map = Area.for_map(map.uid)
      if area_for_map then
         error(("Map '%d' has already been registered with area '%d'"):format(map.uid, area_for_map.uid))
      end
   end

   mapping = nil
   areas[area.uid] = area
end

function Area.create_entrance(area, x, y, params, map)
   params = params or {}
   params.force = true

   map = map or field.map
   assert(class.is_an(InstancedArea, area))
   assert(class.is_an(InstancedMap, map))
   local floor = Area.floor_number(map)
   assert(Area.get(area.uid), "Area is not registered")
   assert(floor, "Map not registered with area")

   local Feat = require("api.Feat")
   local feat, err = Feat.create("elona.stairs_2", x, y, params, map)

   if not feat then
      return feat, err
   end

   feat.area_uid = area.uid
   feat.area_floor = floor

   return feat, nil
end

function Area.is_generated(unique_area_id)
   error("TODO")
end

function Area.get_or_create(unique_area_id)
   error("TODO")
end

return Area
