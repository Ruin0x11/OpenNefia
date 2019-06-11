local Map = require("api.Map")
local pool = require("internal.pool")

local Inventory = class("Inventory")

function Inventory:init(max_size, type_id, x, y)
   self.max_size = max_size or 200
   self.type_id = type_id or "base.item"
   self.x = x or 0
   self.y = y or 0

   -- TODO: UID tracking and positional access aren't necessary here.
   local uids = require("internal.global.uids")
   self.pool = pool:new(self.type_id, uids, 1, 1)

   self.filters = {}
   self.sorted_indices = nil
end

function Inventory:take_from(uid, other)
   -- HACK
   other:transfer_to_with_pos(self.pool, uid, 0, 0)
end

function Inventory:give_to(uid, other)
   -- HACK
   self.pool:transfer_to_with_pos(other, uid, 0, 0)
end

function Inventory:take(uid, map)
   if self.pool:len() >= self.max_size then
      return false
   end

   map = map or Map.current()
   map:get_pool(self.type_id):transfer_to_with_pos(self.pool, uid, 0, 0)

   return self.pool:get(uid)
end

function Inventory:drop(uid, x, y, map)
   map = map or Map.current()
   self.pool:transfer_to_with_pos(map:get_pool(self.type_id), uid, x or self.x, y or self.y)
end

function Inventory:sort_by(comparator)
   if comparator == nil then
      self.sorted_indices = nil
      return
   end

   local indices = table.of(function(i) return i end, self.pool:len())

   local comp = function(i, j)
      return comparator(self.pool:at(i), self.pool:at(j))
   end

   table.sort(indices, comp)
   self.sorted_indices = indices
end

function Inventory:contains(uid)
   return self.pool:exists(uid)
end

function Inventory:iter()
   return self.pool:iter(self.sorted_indices)
end

function Inventory:len()
   return self.pool:len()
end

function Inventory:at(i)
   if self.sorted_indices then
      i = self.sorted_indices[i]
   end
   return self.pool:at(i)
end

return Inventory
