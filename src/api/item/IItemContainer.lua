local ILocation = require("api.ILocation")
local Inventory = require("api.Inventory")

local IItemContainer = class.interface("IItemContainer", {}, {ILocation})

function IItemContainer:init()
end

function IItemContainer:build()
   local container_params = self.proto.container_params
   if container_params and container_params.type == "local" then
      self.inv = Inventory:new(nil, "base.item", self)
   end
end

function IItemContainer:is_item_container()
   return self.inv ~= nil
end

--
-- ILocation impl
--

function IItemContainer:move_object(obj, x, y)
   if not self:is_item_container() then
      return false
   end
   return self.inv:move_object(obj, x, y)
end

function IItemContainer:objects_at_pos(x, y)
   if not self:is_item_container() then
      return fun.iter({})
   end
   return self.inv:objects_at_pos(x, y)
end

function IItemContainer:get_object(uid)
   if not self:is_item_container() then
      return nil
   end
   return self.inv:get_object(uid)
end

function IItemContainer:has_object(obj)
   if not self:is_item_container() then
      return false
   end
   return self.inv:has_object(obj)
end

function IItemContainer:remove_object(obj)
   if not self:is_item_container() then
      return nil
   end
   return self.inv:remove_object(obj)
end

function IItemContainer:is_positional()
   return false
end

function IItemContainer:is_in_bounds(x, y)
   return true
end

function IItemContainer:can_take_object(obj)
   return self:is_item_container()
end

function IItemContainer:take_object(obj)
   if not self:is_item_container() then
      return nil
   end

   return self.inv:take_object(obj)
end

function IItemContainer:iter()
   if not self:is_item_container() then
      return fun.iter({})
   end
   return self.inv:iter()
end


return IItemContainer
