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

function IOwned:get_location()
   local location = self.location or self._parent
   local containing = self

   while location ~= nil do
      if location._parent == nil then
         return location, containing
      end
      containing = location
      if location.get_location then
         location = location:get_location()
      elseif location.location then
         location = location.location
      else
         location = location._parent
      end
   end
end

return IOwned
