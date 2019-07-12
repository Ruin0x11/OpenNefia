local Feat = require("api.Feat")
local Log = require("api.Log")
local Map = require("api.Map")
local InstancedMap = require("api.InstancedMap")

-- Functions dealing with the connections between maps.
--
-- In Elona_next, maps are linked to each other by keeping an
-- outer_uid field on maps with entrances from a map one level up, and
-- through feats on overworlds that hold map UIDs to child maps. To
-- know which map is a parent of another map and where the player
-- should arrive when traveling up a level, it is necessary to find
-- the corresponding feat with an entrance to the inner map in the
-- outer map. To go the other direction, you only have to find the an
-- in the inner map leading to the outer map.
--
-- It is possible for the connection between two maps to go out of
-- sync since there is no global array of connections to maps.
-- However, it should be difficult to cause this in practice as long
-- as this API is used instead of modifying map feats manually.
local MapArea = {}

-- TODO: do not use an implicit Map.current() in any function, since
-- this API is not used as often.

function MapArea.is_entrance(feat)
   return feat.generator_params ~= nil or feat.map_uid ~= nil
end

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

function MapArea.load_outer_map(inner_map)
   inner_map = inner_map or Map.current()

   local outer = inner_map._outer_map_uid
   if not outer then
      return false, "Map doesn't lead anywhere"
   end

   local success, map = Map.load(outer)
   if not success then
      return false, map
   end

   local start_x, start_y = MapArea.find_position_in_outer_map(inner_map, map)

   if not start_x or not start_y then
      Log.warn("Outer map %d does not have entrance for inner map %d.", map.uid, inner_map.uid)
   end

   return true, { map = map, start_x = start_x, start_y = start_y }
end

--- Creates a new entrance leading to an ungenerated map on an outer
--- map.
-- @tparam {id=string,params={...}} generator_params
-- @tparam int x
-- @tparam int y
-- @tparam InstancedMap outer_map
function MapArea.create_entrance(generator_params, x, y, outer_map)
   outer_map = outer_map or Map.current()

   local entrance = Feat.create("elona.stairs_down", x, y, {}, outer_map)
   entrance.generator_params = generator_params

   return entrance
end

--- Generates a map and creates a new entrance leading to it.
-- @tparam {id=string,params={...}} generator_params
-- @tparam int x
-- @tparam int y
-- @tparam InstancedMap outer_map
function MapArea.generate_map_and_entrance(generator_params, x, y, outer_map)
   local entrance = MapArea.create_entrance(generator_params, x, y, outer_map)
   return MapArea.load_map_of_entrance(entrance)
end

--- Sets the entrance of an existing map to an outer map. If an
--- entrance exists already it is removed from the existing outer map.
-- @tparam InstancedMap inner_map
-- @tparam InstancedMap outer_map
-- @tparam int x
-- @tparam int y
function MapArea.set_entrance(inner_map, outer_map, x, y)
   local existing = inner_map._outer_map_uid

   local entrance
   if existing then
      if existing == outer_map.uid then
         entrance = MapArea.find_entrance_in_outer_map(inner_map, outer_map)
         if entrance then
            entrance:set_pos(x, y)
         else
            Log.warn("Could not find entrance in outer map %d", outer_map.uid)
         end

         return
      end

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

   if entrance then
      assert(outer_map:take_object(entrance, x, y))
   else
      entrance = Feat.create("elona.stairs_down", x, y, {}, outer_map)
   end

   entrance.map_uid = inner_map.uid
   inner_map._outer_map_uid = outer_map.uid
   Log.warn("Associating outer map %d with inner map %d", outer_map.uid, inner_map.uid)

   return true
end

--- Given a feat that acts like a map entrance, loads its map and
--- associates it with the map containing the feat if necessary. It
--- will be generated if necessary.
function MapArea.load_map_of_entrance(feat)
   if not MapArea.is_entrance(feat) then
      return false, "Feat is not a map entrance"
   end

   local outer_map = feat:current_map()
   assert(outer_map)

   local success, map
   if feat.map_uid == nil then
      local gen_id = feat.generator_params.generator
      local gen_params = feat.generator_params.params
      success, map = Map.generate(gen_id, gen_params)

      if not success then
         return false, "Couldn't generate map: " .. map
      end

      feat.map_uid = map.uid
      local outer_map_uid = outer_map.uid

      Log.info("Associating map %d with outer map %d", map.uid, outer_map_uid)
      map._outer_map_uid = outer_map_uid
   else
      success, map = Map.load(feat.map_uid)
      if not success then
         return false, "Couldn't load map: " .. map
      end

      if map._outer_map_uid ~= outer_map.uid then
         Log.warn("load_map_of_entrance: map %d not connected to outer map %d, reassociating", map.uid, outer_map.uid)
         map._outer_map_uid = outer_map.uid
      end
   end

   -- TODO: find corresponding exit in inner map, if any

   return true, map
end

local function fold_errors(acc, result, err)
   if not result then
      acc[1] = false
      acc[2] = acc[2] .. "\n\n" .. err
   end
   return acc
end

--- Generates any maps in an outer map that have not been generated
--- yet.
function MapArea.generate_maps_from_entrances(pred, outer_map)
   outer_map = outer_map or Map.current()

   local entrances = MapArea.iter_map_entrances("not_generated", outer_map)
   if pred then
      entrances = entrances:filter(pred)
   end

   local res = entrances
      :each(MapArea.load_map_of_entrance)
      :foldl(fold_errors, {true, ""})

   return table.unpack(res)
end

return MapArea
