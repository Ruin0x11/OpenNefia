local ILocation = require("api.ILocation")

local IOwned = interface("IOwned",
                         {
                            location = { type = ILocation, optional = true }
                         })

function IOwned:remove_ownership()
   if self.location ~= nil then
      self.location:remove_object(self)
      self.location = nil
   end
end

function IOwned:exists()
   return self.location ~= nil
end

return IOwned
