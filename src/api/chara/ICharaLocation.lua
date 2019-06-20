local ILocation = require("api.ILocation")

--- Interface for character inventory. Allows characters to store map
--- objects.
local ICharaLocation = interface("ICharaLocation", {}, {ILocation})

ICharaLocation:delegate("inv",
                        {
                           "is_positional",
                           "move_object",
                           "remove_object",
                           "put_object_into",
                           "move_object",
                           "objects_at_pos",
                           "get_object",
                           "has_object",
                           "iter_objects"
                        })

function ICharaLocation:take_object(obj)
   self.inv:take_object(obj)
   obj.location = self
end


function ICharaLocation:drop_item(item)
   if not self.map then
      Log.warn("Character tried dropping item, but was not in map. %d", self.uid)
      return
   end

   self:put_object_into(self.map, item, self.x, self.y)
end

function ICharaLocation:take_item(item)
   self:take_object(item)
end

return ICharaLocation
