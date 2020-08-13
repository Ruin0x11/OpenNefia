--- @interface IMapObject

local IOwned = require("api.IOwned")
local IObject = require("api.IObject")
local Log = require("api.Log")

-- An IObject that can be displayed on a tilemap.
local IMapObject  = class.interface("IMapObject",
                             {
                                uid = "number",
                                x = "number",
                                y = "number",
                                produce_memory = "function"
                             },
                             {IOwned, IObject})

function IMapObject:init()
   IObject.init(self)

   self.x = 0
   self.y = 0
end

function IMapObject:refresh_cell_on_map()
   local map, obj = self:containing_map()
   if map and class.is_an(IMapObject, obj) then
      map:refresh_tile(obj.x, obj.y)
   end
end

--- Refreshes this map object.
function IMapObject:on_refresh()
   self:refresh_cell_on_map()
end

--- Sets the position of this map object.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] bool force
--- @treturn bool true if succeeded
function IMapObject:set_pos(x, y, force)
   local location = self.location

   assert(location:has_object(self))

   if not location:is_in_bounds(x, y) then
      return false
   end

   local old_x, old_y = self.x, self.y

   location:move_object(self, x, y)

   if location.refresh_tile then
      location:refresh_tile(old_x, old_y)
      location:refresh_tile(x, y)
   end

   return true
end

--- @tparam int dx
--- @tparam int dy
function IMapObject:move(dx, dy)
   return self:set_pos(self.x + dx, self.y + dy)
end

--- Returns the current map this object is contained in, if any.
---
--- @treturn[opt] InstancedMap
--- @see IMapObject:containing_map()
function IMapObject:current_map()
   local InstancedMap = require("api.InstancedMap")
   if class.is_an(InstancedMap, self.location) then
      return self.location
   end

   return nil
end

--- Returns the map this object is contained in, recursively traversing up the
--- locations of each object until a map is found.
---
--- For example, if an item is being held in something's inventory,
--- `IMapObject:current_map()` will return `nil`. Instead,
--- `IMapObject:containing_map()` first gets the current location of the item's
--- containing inventory, and then the containing location of said inventory,
--- and so forth, returning if any location up the tree is an instanced map.
---
--- @treturn[opt] InstancedMap
--- @treturn[opt] IMapObject containing location in the map
--- @see IMapObject:current_map()
function IMapObject:containing_map()
   local InstancedMap = require("api.InstancedMap")
   local location = self.location
   local containing = self

   while location ~= nil do
      if class.is_an(InstancedMap, location) then
         return location, containing
      end
      containing = location
      -- TODO: have to think this over more carefully.
      --
      -- This doesn't handle items being equipped on an EquipSlots, because
      -- EquipSlots has no `location` field - the "location" is its character,
      -- but there is no interface for getting at this location in a standard
      -- way. IOwned doesn't work since EquipSlots isn't a game object, so it
      -- doesn't have a `uid` field (it's required for IOwned). Maybe `uid`
      -- should be removed from IOwned then.
      location = location.location
   end

   return nil
end

--- @treturn bool
function IMapObject:is_in_fov()
   local map = self:current_map()
   if not map then
      return false
   end

   return map:is_in_fov(self.x, self.y)
end

--- @treturn bool
function IMapObject:has_los(from_x, from_y)
   local map = self:current_map()
   if not map then
      return false
   end

   return map:has_los(from_x, from_y, self.x, self.y)
end

--- Produces the data used to display this object in a draw layer.
--- Each draw layer is intended to interpret this data differently
--- depending on what drawing logic is needed.
---
--- @treturn[opt] table
function IMapObject:produce_memory()
   return nil
end

function IMapObject:replace_with(other)
   assert(class.is_an(IMapObject, other))
   assert(self._type == other._type)
   assert(other.location == nil)

   local uid = self.uid
   local location = self.location

   table.replace_with(self, other)

   self.uid = uid
   self.location = location
end

--- @function IMapObject.refresh
--- @inherits IObject.refresh

return IMapObject
