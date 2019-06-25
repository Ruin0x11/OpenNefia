local pool = require("internal.pool")
local ITypedLocation = require("api.ITypedLocation")

-- A pool that stores objects of multiple types.
local multi_pool = class("multi_pool", ITypedLocation)

function multi_pool:init(width, height, uids)
   uids = uids or require("internal.global.uids")

   self.width = width
   self.height = height
   self.uids = uids

   self.subpools = {}
   self.refs = setmetatable({}, { __mode = "v" })

   self.positional = table.of_2d(function() return {} end, width, height, true)
end

function multi_pool:get_subpool(type_id)
   -- TODO: preregister known objects types beforehand
   self.subpools[type_id] = self.subpools[type_id] or pool:new(type_id, self.uids, self.width, self.height)
   return self.subpools[type_id]
end

function multi_pool:is_positional()
   return true
end

function multi_pool:is_in_bounds(x, y)
   return x >= 0 and y >= 0 and x < self.width and y < self.height
end

function multi_pool:take_object(obj, x, y)
   local subpool = self:get_subpool(obj._type)
   subpool:take_object(obj, x, y)
   obj.location = self

   self.refs[obj.uid] = subpool:get_object(obj.uid)
   table.insert(self.positional[obj.y][obj.x], obj.uid)

   return obj
end

function multi_pool:remove_object(obj)
   local obj = self:get_subpool(obj._type):remove_object(obj)
   assert(obj.location == nil)

   self.refs[obj.uid] = nil
   table.iremove_value(self.positional[obj.y][obj.x], obj.uid)

   return obj
end

function multi_pool:put_into(other, obj, x, y)
   local obj = self:get_subpool(obj._type):put_into(other, obj, x, y)

   table.iremove_value(self.positional[obj.y][obj.x], obj.uid)

   return obj
end

function multi_pool:move_object(obj, x, y)
   local prev_x, prev_y = obj.x, obj.y

   local obj = self:get_subpool(obj._type):move_object(obj, x, y)

   table.iremove_value(self.positional[prev_y][prev_x], obj.uid)
   table.insert(self.positional[y][x], obj.uid)

   return obj
end

function multi_pool:objects_at_pos(x, y)
   if not self:is_in_bounds(x, y) then
      return fun.iter({})
   end
   return fun.iter(self.positional[y][x]):map(function(uid) return self:get_object(uid) end)
end

function multi_pool:get_object(uid)
   return self.refs[uid]
end

function multi_pool:has_object(obj)
   return self.refs[obj.uid] ~= nil
end

function multi_pool:iter()
   return fun.iter(self.refs)
end

function multi_pool:iter_type(_type)
   return self:get_subpool(_type):iter()
end

function multi_pool:iter_type_at_pos(_type, x, y)
   return self:get_subpool(_type):objects_at_pos(x, y)
end

function multi_pool:get_object_of_type(_type, uid)
   local obj = self.refs[uid]
   assert(obj._type == _type)
   return obj
end

function multi_pool:can_take_object(obj)
   return true
end

return multi_pool
