local ILocation = require("api.ILocation")

local IOwned = class.interface("IOwned",
                         {
                            location = { type = ILocation, optional = true },
                            _parent = { type = ILocation, optional = true }
                         })

function IOwned:remove_ownership(no_events)
   local location = self:get_location()
   if location ~= nil then
      if not no_events then
         self:emit("base.on_object_removed")
      end
      assert(location:remove_object(self))
      assert(self.location == nil)
   end
end

-- Gets the top-level location of this object.
--
-- This function will traverse ILocation _parent fields until it reaches
-- either an IOwned (which has a location field) or a location without a
-- parent.
--
-- So if an item is contained in a EquipSlots, whose `_parent` points to a
-- `base.chara` map object contained inside an InstancedMap, the location
-- returned from here is the map object.
--
-- Contrast with IMapObject:containing_map(), which would return the
-- InstancedMap instead, because it follows both the location's `_parent` field
-- and the map object's `location` field.
function IOwned:get_location()
   local location = self.location or self._parent
   local containing = self
   local containing2 = nil

   while location ~= nil do
      if location._parent == nil then
         return location, containing
      elseif location.location ~= nil then
         return containing, containing2
      end
      containing2 = containing
      containing = location
      location = location._parent
   end
end

return IOwned
