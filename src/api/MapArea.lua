--- Functions dealing with the connections between maps.
---
--- In Elona_next, maps are linked to each other by keeping a private
--- _outer_map_uid field on maps with entrances from a map one level
--- up, and through feats on overworlds that hold map UIDs to child
--- maps. To know which map is a parent of another map and where the
--- player should arrive when traveling up a level, it is necessary to
--- find the corresponding feat with an entrance to the inner map in
--- the outer map. To go the other direction, you only have to find the
--- entrance in the inner map leading to the outer map.
---
--- It is possible for the connection between two maps to go out of
--- sync since there is no global array of connections to maps.
--- However, it should be difficult to cause this in practice as long
--- as this API is used instead of modifying map feats manually.
--- @module MapArea

local Feat = require("api.Feat")
local Log = require("api.Log")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")
local data = require("internal.data")
local MapArea = {}

-- TODO: do not use an implicit Map.current() in any function, since
-- this API is not used as often.

--- Returns true if this feat acts as an entrace to another map.
---
--- @tparam IFeat feat
--- @treturn bool
function MapArea.is_entrance(feat)
   return feat.generator_params ~= nil or feat.map_uid ~= nil
end

--- Iterates the entraces on a map.
---
--- @tparam[opt] string kind Which entrances to iterate.
---   - any: iterate all entrances. (default)
---   - generated: only interate entrances leading to generated maps.
---   - not_generated: only interate entrances not leading to generated maps.
--- @tparam[opt] InstancedMap map Defaults to the current map.
--- @treturn Iterator(IFeat)
function MapArea.iter_map_entrances(kind, map)
   kind = kind or "any"
   map = map or Map.current()

   local pred

   if kind == "any" then
      pred = MapArea.is_entrance
   elseif kind == "generated" then
      -- NOTE: entrances created with MapArea.set_entrance() will not
      -- have a generator_params field.
      pred = function(feat) return feat.map_uid ~= nil end
   elseif kind == "not_generated" then
      pred = function(feat) return feat.generator_params ~= nil and feat.map_uid == nil end
   else
      error("'kind' must be 'any', 'generated' or 'not_generated'")
   end

   return map:iter_feats():filter(pred)
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

--- Given an inner and outer map, finds the position in the outer map
--- that the inner map will lead to when traveling from the inner to
--- the outer map. This should be the same position as the position of
--- the stairs in the outer map that lead to the inner map. If there
--- is no entrance leading to the inner map on the outer map, nil is
--- returned.
---
--- @tparam InstancedMap inner_map
--- @tparam[opt] InstancedMap outer_map Defaults to the current map.
--- @treturn[opt] int x
--- @treturn[opt] int y
function MapArea.find_position_in_outer_map(inner_map, outer_map)
   outer_map = outer_map or Map.current()

   if inner_map._outer_map_uid == outer_map.uid
   and inner_map._outer_map_x
   and inner_map._outer_map_y
   then
      return inner_map._outer_map_x, inner_map._outer_map_y
   end

   local entrance = MapArea.find_entrance_in_outer_map(inner_map, outer_map)
   if entrance then
      return entrance.x, entrance.y
   end

   return nil
end

--- Given an inner map, loads its outer map.
---
--- @treturn bool success
--- @treturn {map=InstancedMap,start_x=int,start_y=int}|string result/error
function MapArea.load_outer_map(inner_map)
   inner_map = inner_map or Map.current()

   local outer = inner_map._outer_map_uid
   if not outer then
      return false, "Map doesn't lead anywhere"
   end

   local success, err = Map.load(outer)
   if not success then
      return false, err
   end

   local map = err
   local start_x, start_y = MapArea.find_position_in_outer_map(inner_map, map)

   if not start_x or not start_y then
      Log.warn("Outer map %d does not have entrance for inner map %d.", map.uid, inner_map.uid)
   end

   return true, { map = map, start_x = start_x, start_y = start_y }
end

--- Creates a new entrance leading to an ungenerated map on an outer
--- map.
---
--- @tparam {id=id:base.map_generator,params=table} generator_params
--- @tparam int|table area_params An area UID or data table.
--- @tparam int x
--- @tparam int y
--- @tparam InstancedMap outer_map
--- @treturn IFeat
function MapArea.create_entrance(generator_params, area_params, x, y, outer_map)
   outer_map = outer_map or Map.current()

   if type(area_params) == "table" then
      assert(area_params.outer_map_id, "area must have outer map ID")
   end

   local entrance = Feat.create("elona.map_entrance", x, y, {}, outer_map)
   entrance.generator_params = generator_params
   entrance.area_params = area_params

   local generator = data["base.map_generator"]:ensure(generator_params.generator)
   if generator.get_image then
      local image = generator.get_image(generator_params.params)
      if image then
         entrance.image = image
      end
   end

   return entrance
end

--- Sets the entrance of an existing map to an outer map. If an
--- entrance exists already it is removed from the existing outer map.
--- The entrance is created at (x, y) in the outer map.
---
--- @tparam InstancedMap inner_map
--- @tparam InstancedMap outer_map
--- @tparam int x
--- @tparam int y
--- @treturn bool success
function MapArea.set_entrance(inner_map, outer_map, x, y)
   local existing = inner_map._outer_map_uid

   local entrance
   if existing then
      if existing == outer_map.uid then
         entrance = MapArea.find_entrance_in_outer_map(inner_map, outer_map)
         if entrance then
            entrance:set_pos(x, y)
            return
         else
            Log.warn("Could not find entrance in outer map %d", outer_map.uid)
            -- Fall through and create the entrance below.
         end
      else
         local function remove_entrance(map)
            entrance = MapArea.find_entrance_in_outer_map(inner_map, map)
            if entrance then
               entrance:remove_ownership()
            else
               Log.warn("Could not find entrance in existing outer map %d", map.uid)
            end
         end

         local ok, err = Map.edit(existing, remove_entrance)
         if not ok then
            Log.warn("Could not remove existing entrance: %s", err)
         end
      end
   end

   if entrance then
      assert(outer_map:take_object(entrance, x, y))
   else
      entrance = Feat.create("elona.map_entrance", x, y, {}, outer_map)
   end

   entrance.map_uid = inner_map.uid
   inner_map._outer_map_uid = outer_map.uid
   Log.warn("Associating outer map %d with inner map %d", outer_map.uid, inner_map.uid)

   return true
end

--- Given a feat that acts like a map entrance, loads its inner map.
--- It will be generated if necessary.
---
--- @tparam IFeat feat
--- @tparam bool associate If true, associates the inner map with the
--- outer map if it's an entrance.
--- @treturn bool success
--- @treturn InstancedMap|string result/error
function MapArea.load_map_of_entrance(feat, associate)
   if not MapArea.is_entrance(feat) then
      return false, "Feat is not a map entrance"
   end

   local outer_map = feat:current_map()
   assert(outer_map)

   local success, map
   if feat.map_uid == nil then
      local gen_id = feat.generator_params.generator
      local gen_params = feat.generator_params.params
      gen_params.area_params = feat.area_params

      success, map = Map.generate(gen_id, gen_params)

      if not success then
         return false, "Couldn't generate map: " .. map
      end
   else
      success, map = Map.load(feat.map_uid)
      if not success then
         return false, "Couldn't load map: " .. map
      end
   end

   if associate then
      -- BUG: This can happen if two maps both contain entrances
      -- pointing to one another. This means when trying to leave
      -- either map the player will be moved into the other one
      -- indefinitely.
      assert(feat.map_uid ~= outer_map.uid, "Cannot create circular reference between inner/outer maps")

      local is_entrance = feat._id == "elona.map_entrance"
      assert(is_entrance)

      feat.map_uid = map.uid
      local outer_map_uid = outer_map.uid

      Log.info("Associating map %d with outer map %d", map.uid, outer_map_uid)
      map._outer_map_uid = outer_map_uid
   end

   return true, map
end

return MapArea
