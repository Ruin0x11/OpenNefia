local ILocation = require("api.ILocation")

local IOwned = class.interface("IOwned",
                         {
                            location = { type = ILocation, optional = true }
                         })

function IOwned:remove_ownership(no_events)
   if self.location ~= nil then
      if not no_events then
         self:emit("base.on_object_removed")
      end
      assert(self.location:remove_object(self))
      self.location = nil
   end
end

--- Returns the current map this object is contained in, if any.
---
--- @treturn[opt] InstancedMap
--- @see IOwned:containing_map()
function IOwned:current_map()
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
--- `IOwned:current_map()` will return `nil`. Instead,
--- `IOwned:containing_map()` first gets the current location of the item's
--- containing inventory, and then the containing location of said inventory,
--- and so forth, returning if any location up the tree is an instanced map.
---
--- @treturn[opt] InstancedMap
--- @treturn[opt] IOwned containing location in the map
--- @see IOwned:current_map()
function IOwned:containing_map()
   local InstancedMap = require("api.InstancedMap")
   local location = self.location
   local containing = self

   while location ~= nil do
      if class.is_an(InstancedMap, location) then
         return location, containing
      end
      containing = location
      location = location.location
   end

   return nil
end

return IOwned
