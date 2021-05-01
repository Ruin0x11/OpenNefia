--- @module Mef
local Log = require("api.Log")

local Event = require("api.Event")
local Map = require("api.Map")
local MapObject = require("api.MapObject")
local ILocation = require("api.ILocation")
local field = require("game.field")

local Mef = {}

--- Iterates the mefs at the given position.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
function Mef.at(x, y, map)
   map = map or field.map

   if not map:is_in_bounds(x, y) then
      return fun.iter({})
   end

   return map:iter_type_at_pos("base.mef", x, y):nth(1)
end

--- Iterates all mefs in the map.
---
--- @tparam[opt] InstancedMap map
--- @treturn Iterator(IMef)
function Mef.iter(map)
   return (map or field.map):iter_type("base.mef")
end

--- Returns true if this mef is valid.
---
--- @tparam[opt] IMef mef
--- @tparam[opt] InstancedMap map Map to check for existence in
function Mef.is_alive(mef, map)
   map = map or Map.current()
   if type(mef) ~= "table" then
      return false
   end

   if map == nil then
      return mef:current_map() ~= nil
   end

   local their_map = mef:current_map()
   if not their_map then
      return false
   end

   return their_map.uid == map.uid
end

--- Creates a new mef. Returns the mef on success, or nil if
--- creation failed.
---
--- @tparam id:base.mef id
--- @tparam[opt] int x Defaults to a random free position on the map.
--- @tparam[opt] int y
--- @tparam[opt] table params Extra parameters.
---  - ownerless (bool): Do not attach the mef to a map. If true, then `where` is ignored.
---  - no_build (bool): Do not call :build() on the object.
---  - approximate_pos (bool): If position is not accessable, put the mef somewhere close.
---  - allow_stacking (bool): If true, ignore items on the ground when
---    checking for tile openness.
---  - origin (IMapObject): Thing that created this mef, to check if the player
---    should be accused of hurting something indirectly through it.
---  - duration (uint): How many turns the mef should last. Defaults to 10. -1 means the mef will never be removed.
---  - power (uint): Power of the mef. Defaults to 0.
--- @tparam[opt] ILocation where Where to instantiate this mef.
---   Defaults to the current map.
--- @treturn[opt] IMef
--- @treturn[opt] string error
--- @hsp addMef x, y, id, pic, params.duration, params.power, params.origin, ref, ref2, color
function Mef.create(id, x, y, params, where)
   params = params or {}
   params.allow_stacking = params.allow_stacking or true
   params.approximate_pos = params.approximate_pos or false

   if params.ownerless then
      where = nil
   else
      if where == nil then
         Log.warn("Implicit global map used in Mef.create().")
         if Log.has_level("debug") then
            Log.debug("%s", debug.traceback())
         end
      end
      where = where or field.map
   end

   if not class.is_an(ILocation, where) and not params.ownerless then
      return nil, "invalid location"
   end

   if where and where:is_positional() then
      if x == nil or y == nil then
         x, y = Map.find_free_position(x, y, {only_map=true}, where)
      end
      if not Map.is_floor(x, y, where) then
         return nil, "cannot access tile"
      end
   end

   local origin_uid
   if params.origin then
      assert(class.is_an("api.IMapObject", params.origin))
      origin_uid = params.origin.uid
   end

   local gen_params = {
      no_build = params.no_build,
      build_params = params
   }
   local mef = MapObject.generate_from("base.mef", id)

   mef.origin_uid = origin_uid
   mef.turns = params.duration or 10
   mef.power = params.power or 0

   if where then
      local other_mef = Mef.at(x, y, where)
      if other_mef then
         where:remove_object(other_mef)
      end

      mef = where:take_object(mef, x, y)

      if not mef then
         if other_mef then
            assert(where:take_object(other_mef, x, y))
         end
         return nil, "location failed to receive mef"
      end
      assert(mef:get_location() == where)
      assert(mef:current_map())
   end

   local ok, err = xpcall(MapObject.finalize, debug.traceback, mef, gen_params)
   if not ok then
      Log.error(err)
      mef:remove_ownership()
      return nil, err
   end

   mef:refresh()

   return mef
end

return Mef
