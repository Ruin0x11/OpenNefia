local ILocation = require("api.ILocation")
local pool = require("internal.pool")
local save = require("internal.global.save")
local IOwned = require("api.IOwned")
local IContainer = require("api.IContainer")

local Inventory = class.class("Inventory", IContainer)

function Inventory:init(max_capacity, type_id, owner)
   if owner then
      assert(class.is_an(IOwned, owner))
      self._parent = owner
   end
   self.max_capacity = math.max(math.floor(max_capacity or 200), 1)
   self.type_id = type_id or "base.item"
   self.max_weight = nil

   self.pool = pool:new(self.type_id, 1, 1, self)

   self.filters = {}
end

function Inventory:set_owner(owner)
   assert(class.is_an(IOwned, owner))
   self._parent = owner
end

function Inventory:is_full()
   return self:len() >= self.max_capacity
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
   return self.max_capacity - self:len()
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

--
-- IContainer impl
--

function Inventory:get_max_capacity()
   return self.max_capacity
end

function Inventory:set_max_capacity(max_capacity)
   self.max_capacity = max_capacity
end

function Inventory:get_max_item_weight()
   return self.max_weight
end

function Inventory:set_max_item_weight(max_weight)
   self.max_weight = max_weight
end

return Inventory
