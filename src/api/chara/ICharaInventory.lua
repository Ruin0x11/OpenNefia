local Inventory = require("api.Inventory")
local ILocation = require("api.ILocation")

--- Interface for character inventory. Allows characters to store map
--- objects.
local ICharaInventory = class.interface("ICharaInventory", {}, {ILocation})

ICharaInventory:delegate("inv",
                        {
                           "is_positional",
                           "move_object",
                           "remove_object",
                           "move_object",
                           "can_take_object",
                           "is_in_bounds",
                           "objects_at_pos",
                           "get_object",
                           "has_object",
                           "iter"
                        })

function ICharaInventory:init()
   self.inv = Inventory:new(200)
end

function ICharaInventory:take_object(obj)
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


function ICharaInventory:drop_item(item, amount)
   if not self:has_item_in_inventory(item) then
      Log.warn("Character %d tried dropping item, but it was not in their inventory. %d", self.uid, item.uid)
      return nil
   end

   local map = self:current_map()
   if not map then
      Log.warn("Character tried dropping item, but was not in map. %d", self.uid)
      return nil
   end

   return item:move_some(amount, map, self.x, self.y)
end

function ICharaInventory:has_item_in_inventory(item)
   return self.inv:has_object(item)
end

function ICharaInventory:take_item(item, amount)
   amount = amount or item.amount

   local success

   if amount == item.amount then
      success = self:take_object(item)

      if success then
         item:stack()
      end

      return success
   else
      local separated = item:move_some(amount, self)

      if separated then
         separated:stack()
      end

      return separated
   end
end

function ICharaInventory:iter_inventory()
   return self.inv:iter()
end

function ICharaInventory:owns_item(item)
   -- TODO
   return item.ownership == "none"
end

return ICharaInventory
