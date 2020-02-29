--- @module Feat

local Event = require("api.Event")
local Map = require("api.Map")
local MapObject = require("api.MapObject")
local ILocation = require("api.ILocation")
local field = require("game.field")

local Feat = {}

--- Iterates the feats at the given position.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
function Feat.at(x, y, map)
   map = map or field.map

   if not map:is_in_bounds(x, y) then
      return fun.iter({})
   end

   return map:iter_type_at_pos("base.feat", x, y)
end

--- Iterates all feats in the map.
---
--- @tparam[opt] InstancedMap map
--- @treturn Iterator(IFeat)
function Feat.iter(map)
   return (map or field.map):iter_feats()
end

--- Returns true if this feat is valid.
---
--- @tparam[opt] IFeat feat
--- @tparam[opt] InstancedMap map Map to check for existence in
function Feat.is_alive(feat, map)
   map = map or Map.current()
   if type(feat) ~= "table" then
      return false
   end

   if map == nil then
      return feat:current_map() ~= nil
   end

   local their_map = feat:current_map()
   if not their_map then
      return false
   end

   return their_map.uid == map.uid
end

--- Creates a new feat. Returns the feat on success, or nil if
--- creation failed.
---
--- @tparam id:base.feat id
--- @tparam[opt] int x Defaults to a random free position on the map.
--- @tparam[opt] int y
--- @tparam[opt] table params Extra parameters.
---  - ownerless (bool): Do not attach the feat to a map. If true, then `where` is ignored.
---  - no_build (bool): Do not call :build() on the object.
---  - approximate_pos (bool): If position is not accessable, put the feat somewhere close.
---  - allow_stacking (bool): If true, ignore items on the ground when
---    checking for tile openness.
--- @tparam[opt] ILocation where Where to instantiate this feat.
---   Defaults to the current map.
--- @treturn[opt] IFeat
--- @treturn[opt] string error
function Feat.create(id, x, y, params, where)
   params = params or {}
   params.allow_stacking = params.allow_stacking or true
   params.approximate_pos = params.approximate_pos or false

   if params.ownerless then
      where = nil
   else
      where = where or field.map
   end

   if not class.is_an(ILocation, where) and not params.ownerless then
      return nil, "invalid location"
   end

   if where and where:is_positional() then
      if x == nil or params.approximate_pos then
         x, y = Map.find_free_position(x, y, {only_map=true, allow_stacking=params.allow_stacking}, where)
      end
      if not x then
         return nil, "out of bounds"
      end
      if not Map.can_access(x, y, where) then
         return nil, "cannot access tile"
      end
   end

   local gen_params = {
      no_build = params.no_build
   }
   local feat = MapObject.generate_from("base.feat", id, gen_params)

   if where then
      feat = where:take_object(feat, x, y)

      if not feat then
         return nil, "location failed to receive feat"
      end
      assert(feat.location == where)
      assert(feat:current_map())
   end

   feat:instantiate()

   feat:refresh()

   return feat
end

return Feat
