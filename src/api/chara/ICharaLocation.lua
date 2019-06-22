local ILocation = require("api.ILocation")

--- Interface for character inventory. Allows characters to store map
--- objects.
local ICharaLocation = interface("ICharaLocation", {}, {ILocation})

ICharaLocation:delegate("inv",
                        {
                           "is_positional",
                           "move_object",
                           "remove_object",
                           "move_object",
                           "can_take_object",
                           "objects_at_pos",
                           "get_object",
                           "has_object",
                           "iter_objects"
                        })

function ICharaLocation:init()
   self.inventory_weight = 0
   self.max_inventory_weight = 1000
end

function ICharaLocation:take_object(obj)
   if not self:can_take_object(obj) then
      return nil
   end

   if not self.inv:take_object(obj) then
      return nil
   end

   obj.location = self
   self:refresh_weight()

   return obj
end

function ICharaLocation:put_into(other, obj, x, y)
   local result = self.inv:put_into(other, obj, x, y)
   self:refresh_weight()

   return result
end


function ICharaLocation:refresh_weight()
   local weight = 0
   for _, i in self:iter_items() do
      weight = weight + i:calc("weight")
   end
   for _, i in self:iter_equipment() do
      weight = weight + i:calc("weight")
   end
   self.inventory_weight = weight
   self.max_inventory_weight = 1000
end

function ICharaLocation:drop_item(item)
   local map = self:current_map()
   if not map then
      Log.warn("Character tried dropping item, but was not in map. %d", self.uid)
      return nil
   end

   return self:put_into(map, item, self.x, self.y)
end

function ICharaLocation:take_item(item)
   return self:take_object(item)
end

function ICharaLocation:has_item(item)
   return self:has_object(item)
end

function ICharaLocation:iter_items()
   return self.inv:iter_objects()
end

return ICharaLocation
