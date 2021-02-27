local ILocation = require("api.ILocation")
local pool = require("internal.pool")
local save = require("internal.global.save")
local IOwned = require("api.IOwned")

local Inventory = class.class("Inventory", ILocation)

function Inventory:init(max_size, type_id, owner)
   if owner then
      assert(class.is_an(IOwned, owner))
      self._parent = owner
   end
   self.max_size = max_size or 200
   self.type_id = type_id or "base.item"
   self.max_weight = nil

   self.pool = pool:new(self.type_id, 1, 1, self)

   self.filters = {}
end

function Inventory:set_max_size(max_size)
   self.max_size = max_size
end

function Inventory:is_full()
   return self:len() >= self.max_size
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

function Inventory:free_slots()
   return self.max_size - self:len()
end

-- Gets or creates a new inventory at the given ID.
--
-- @tparam string id
-- @treturn Inventory
function Inventory.get_or_create(id)
   local i = save.base.inventories[id]
   if i == nil then
      i = Inventory.create(id)
   end
   return i
end

-- Creates a new inventory at the given ID, overwriting any existing one.
--
-- @tparam string id
-- @treturn Inventory
function Inventory.create(id)
   save.base.inventories[id] = Inventory:new()
   return save.base.inventories[id]
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

   return self.pool:take_object(obj)
end

return Inventory
