local InstancedMap = require("api.InstancedMap")
local InstancedArea = require("api.InstancedArea")
local field = require("game.field")
local save = require("internal.global.save")
local Log = require("api.Log")
local data = require("internal.data")

--- An area is a collection of maps. Areas commonly represent dungeons or world
--- maps.
---
--- When you save a map, if it is not associated with an area then one will be
--- created and registered for it.
--- 
--- The process of creating an area is as follows:
---
--- 1. Create one or more instances of InstancedMap and *be sure to call
--- Map.save() on each one* before continuing. To keep things in sync the map
--- must exist on disk before registering an area that contains it.
---
--- 2. Create an InstancedArea and call :add_floor(map[, floor_number]) to add
--- the floors of the area in sequence.
---
--- 3. Call Area.register(instanced_area, { parent = parent }) to register the
--- area globally. To make this area a root area (nothing parented with it, e.g.
--- world maps) then pass the string "root" as `parent`. Otherwise, pass in an
--- InstancedArea that has already been registered with Area.register() (for
--- example from Area.get(uid) or Area.for_map(instanced_map)).
---
--- 4. Call Area.create_entrance(instanced_area, x, y, feat_params, map) to
--- create an entrance to the area on a given map. If you do this after
--- registering an area *don't forget to call* `Map.save(map)`, or the newly
--- created entrance will be lost when you load the map from disk.
local Area = {}

function Area.get(uid)
   assert(type(uid) == "number")

   local areas = save.base.areas

   return areas[uid] or nil
end

function Area.current()
   return Area.for_map(field.map)
end

function Area.iter()
   return fun.iter_pairs(save.base.areas)
end

function Area.iter_in_parent(parent_map)
   local is_area_entrance = function(feat)
      -- TODO: this might be too permissive of a filter, but that's
      -- what I get for using a dynamic language...
      return feat.params.area_uid and feat.params.area_floor

   end
   local to_area = function(feat)
      return Area.get(feat.params.area_uid)
   end
   return parent_map:iter_feats():filter(is_area_entrance):map(to_area)
end

function Area.metadata(map)
   local area = Area.for_map(map or field.map)

   if area == nil then
      return nil
   end

   return area.metadata
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
   if area == nil or area.parent_area == nil or area.parent_area == "root" then
      return nil
   end
   return Area.get(area.parent_area)
end

function Area.get_root_area(map_or_area)
   local area = get_area(map_or_area)
   while area do
      if area.parent_area == nil then
         return area
      end
      area = Area.parent(area)
   end
   return nil
end

function Area.iter_children(map_or_area)
   local area = get_area(map_or_area)
   return Area.iter():filter(function(uid, a) return a.parent_area == area.uid end)
end

function Area.iter_all_contained_in(map_or_area)
   local area = get_area(map_or_area)
   local found = table.set {}
   local stack = {area}
   local result = {}
   while #stack > 0 do
      local area = stack[#stack]
      stack[#stack] = nil
      if not found[area] then
         result[#result+1] = area
         found[area] = true
         for _, child in Area.iter_children(area) do
            stack[#stack+1] = Area.get(child)
         end
      end
   end
   return fun.iter(result):map(function(a) return a.uid, a end)
end

function Area.for_map(map_or_uid)
   local uid = map_or_uid
   if class.is_an(InstancedMap, map_or_uid) then
      uid = map_or_uid.uid
   end
   assert(type(uid) == "number", "UID must be number")

   local areas = save.base.areas

   local mapping = {}
   for _, _, area in fun.iter_pairs(areas) do
      for _, _, map_meta in area:iter_maps() do
         mapping[map_meta.uid] = area
      end
   end

   return mapping[uid]
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

function Area.is_registered(area)
   local uid = area
   if class.is_an(InstancedArea, area) then
      uid = area.uid
   end
   return save.base.areas[uid] ~= nil
end

-- TODO move `parent` into a required parameter
function Area.register(area, opts)
   opts = opts or {}
   opts.parent = opts.parent or nil
   assert(class.is_an(InstancedArea, area))

   if class.is_an(InstancedArea, opts.parent) then
      area.parent_area = opts.parent.uid
   end

   if area.parent_area == nil and opts.parent ~= "root" then
      error(("%s should have parent world map area set"):format(area))
   end

   if opts.parent ~= "root" then
      assert(save.base.areas[area.parent_area], ("Parent area '%d' has not been registered yet"):format(area.parent_area))
   end

   local areas = save.base.areas

   assert(areas[area.uid] == nil, "Area has already been registered")

   Log.debug("Registering area '%s' with maps: %s", area.name, inspect(fun.iter(area.maps):extract("uid"):to_list()))

   -- for _, _, map in area:iter_maps() do
   --    if not Map.exists(map.uid) then
   --       Log.warn("Map '%d' is not yet saved, call `Map.save(uid)` afterwards", map.uid, map.uid)
   --    end
   -- end

   areas[area.uid] = area
end

function Area.create_entrance(area, map_or_floor_number, x, y, params, map)
   params = params or {}
   params.force = true
   map = map or field.map

   assert(class.is_an(InstancedArea, area))
   assert(class.is_an(InstancedMap, map))

   local floor
   if class.is_an(InstancedMap, map_or_floor_number) then
      floor = Area.floor_number(map)
      assert(map.area_uid == area.uid, "Map is not registered with this area")
      assert(floor, "Map does not have a floor in the area")
   elseif math.type(map_or_floor_number) == "integer" then
      floor = map_or_floor_number
   else
      error(("unknown floor number '%s'"):format(map_or_floor_number))
   end

   local Feat = require("api.Feat")
   local feat, err = Feat.create("elona.map_entrance", x, y, params, map)

   if not feat then
      return feat, err
   end

   feat.params.area_uid = area.uid
   feat.params.area_floor = floor
   if area.image then
      feat.image = area.image
   end

   return feat, nil
end

function Area.create_stairs_down(area, floor_number, x, y, params, map)
   local Feat = require("api.Feat")
   local stairs = Feat.create("elona.stairs_down", x, y, params, map)
   if stairs then
      stairs.params.area_uid = area.uid
      stairs.params.area_floor = floor_number
   end
   return stairs
end

function Area.create_stairs_up(area, floor_number, x, y, params, map)
   local Feat = require("api.Feat")
   local stairs = Feat.create("elona.stairs_up", x, y, params, map)
   if stairs then
      stairs.params.area_uid = area.uid
      stairs.params.area_floor = floor_number
   end
   return stairs
end

function Area.is_created(area_archetype_id)
   return save.base.unique_areas[area_archetype_id] ~= nil
end

function Area.get_unique(area_archetype_id)
   data["base.area_archetype"]:ensure(area_archetype_id)
   local entry = save.base.unique_areas[area_archetype_id]
   if entry ~= nil then
      return Area.get(entry.area_uid)
   end

   return nil
end

function Area.create_unique(area_archetype_id, parent)
   if Area.is_created(area_archetype_id) then
      return Area.get_unique(area_archetype_id)
   end

   data["base.area_archetype"]:ensure(area_archetype_id)

   assert(parent == "root" or class.is_an(InstancedArea, parent), "Invalid parent area")

   local area = InstancedArea:new(area_archetype_id)
   Area.register(area, { parent = parent })

   save.base.unique_areas[area_archetype_id] = {
      area_uid = area.uid,
      entrance_was_generated = false
   }

   return area
end

return Area
