local ILocation = require("api.ILocation")

local IOwned = class.interface("IOwned",
                         {
                            uid = "number",
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

return IOwned
