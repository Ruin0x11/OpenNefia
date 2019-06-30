local Map = require("api.Map")
local ILocation = require("api.ILocation")
local pool = require("internal.pool")

local Inventory = class.class("Inventory", ILocation)

function Inventory:init(max_size, type_id)
   self.max_size = max_size or 200
   self.type_id = type_id or "base.item"

   -- TODO: UID generation and positional access aren't necessary here.
   local uids = require("internal.global.uids")
   self.pool = pool:new(self.type_id, uids, 1, 1)

   self.filters = {}
end

function Inventory:is_full()
   return self.pool:object_count() >= self.max_size
end

function Inventory:sorted_by(comparator)
   local indices = fun.range(self.pool:len()):to_list()

   local comp = function(i, j)
      return comparator(self.pool:at(i), self.pool:at(j))
   end

   table.sort(indices, comp)
   return fun.iter(indices):map(function(ind) return self:at(ind) end)
end

function Inventory:contains(item)
   return self.pool:has_object(item)
end

function Inventory:iter()
   return self.pool:iter()
end

function Inventory:len()
   return self.pool:object_count()
end

--
-- ILocation impl
--

Inventory:delegate("pool",
                   {
                      "move_object",
                      "remove_object",
                      "objects_at_pos",
                      "get_object",
                      "has_object",
                      "iter"
                   })

function Inventory:is_positional()
   return false
end

function Inventory:is_in_bounds()
   return true
end

function Inventory:can_take_object(obj)
   return not self:is_full() and obj._type == self.type_id
end

function Inventory:take_object(obj)
   if not self:can_take_object(obj) then
      return nil
   end

   if not self.pool:take_object(obj) then
      return nil
   end

   obj.location = self
   return obj
end

return Inventory
