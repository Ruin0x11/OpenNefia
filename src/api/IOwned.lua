local ILocation = require("api.ILocation")

local IOwned = interface("IOwned",
                         {
                            uid = "number",
                            location = { type = ILocation, optional = true }
                         })

function IOwned:remove_ownership()
   if self.location ~= nil then
      assert(self.location:remove_object(self))
      self.location = nil
   end
end

return IOwned
