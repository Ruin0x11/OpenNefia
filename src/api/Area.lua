local InstancedMap = require("api.InstancedMap")
local InstancedArea = require("api.InstancedArea")
local field = require("game.field")
local save = require("internal.global.save")
local Log = require("api.Log")

--- An area is a collection of maps. Areas commonly represent dungeons or world maps.
---
--- When you save a map, if it is not associated with an area then one will be created and registered for it.
--- 
--- The process of creating an area is as follows:
---
--- 1. Create one or more instances of InstancedMap and *be sure to call Map.save() on each one* before continuing. To keep things in sync the map must exist on disk before registering an area that contains it.
--- 2. Create an InstancedArea and call :add_floor(map[, floor_number]) to add the floors of the area in sequence.
--- 3. Call Area.register(instanced_area, { parent = parent }) to register the area globally. To make this area a root area (nothing parented with it, e.g. world maps) then pass the string "root" as `parent`. Otherwise, pass in an InstancedArea that has already been registered with Area.register() (for example from Area.get(uid) or Area.for_map(instanced_map)).
--- 4. Call Area.create_entrance(instanced_area, x, y, feat_params, map) to create an entrance to the area on a given map. If you do this after registering an area *don't forget to call* `Map.save(map)`, or the newly created entrance will be lost when you load the map from disk.
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

function Area.iter()
   return fun.iter_pairs(save.base.areas)
end

local function get_area(map_or_area)
   local area = map_or_area
   if class.is_an(InstancedMap, map_or_area) then
      area = Area.for_map(map_or_area)
   end
   assert(area == nil or class.is_an(InstancedArea, area))
   return area
end

function Area.parent(map_or_area)
   local area = get_area(map_or_area)
   if area == nil or area.parent_area == nil then
      return nil
   end
   return Area.get(area.parent_area)
end

function Area.iter_children(map_or_area)
   local area = get_area(map_or_area)
   return Area.iter():filter(function(uid, a) return a.parent_area == area.uid end)
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

function Area.register(area, opts)
   opts = opts or {}
   opts.parent = opts.parent or nil
   assert(class.is_an(InstancedArea, area))

   if area.name == nil then
      error(("Area '%d' should have a name set"):format(area.uid))
   end

   if class.is_an(InstancedArea, opts.parent) then
      area.parent_area = opts.parent.uid
   end

   if area.parent_area == nil and not opts.parent == "root" then
      error(("Area '%s' should have parent world map area set"):format(area.name))
   end

   assert(save.base.areas[area.parent_area], ("Parent area '%d' has not been registered yet"):format(area.parent_area))

   local areas = save.base.areas

   assert(areas[area.uid] == nil, "Area has already been registered")

   local Map = require("api.Map")

   Log.info("Registering area '%s' with maps: %s", area.name, inspect(fun.iter(area.maps):extract("uid"):to_list()))

   for _, _, map in area:iter_maps() do
      assert(Map.is_saved(map.uid), ("Map '%d' must be saved before registering an area with it"):format(map.uid))
   end

   mapping = nil
   areas[area.uid] = area

   area.metadata.can_return_to = true
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
   local feat, err = Feat.create("elona.stairs_down", x, y, params, map)

   if not feat then
      return feat, err
   end

   feat.area_uid = area.uid
   feat.area_floor = floor
   if area.image then
      feat.image = area.image
   end

   return feat, nil
end

function Area.is_generated(unique_area_id)
   error("TODO")
end

function Area.get_or_create(unique_area_id)
   error("TODO")
end

return Area
