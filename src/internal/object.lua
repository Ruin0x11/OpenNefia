local env = require("internal.env")
local data = require("internal.data")

local object = {}

function object.__index(t, k)
   if k == "_serialize" then
      return object.serialize
   end
   if k == "_deserialize" then
      return object.deserialize
   end
   if k == "_mt" then
      local mt = getmetatable(t)
      return env.get_require_path(mt.__iface)
   end
   if k == "proto" then
      local mt = getmetatable(t)
      return mt.__proto
   end

   local v = rawget(t, k)
   if v ~= nil then
      return v
   end

   local mt = getmetatable(t)
   v = mt.__proto[k]
   if v ~= nil then
      return v
   end

   return mt.__iface[k]
end

function object.serialize(self)
   local ret = table.deepcopy(self)
   ret._type = ret.proto._type
   ret._id = ret.proto._id
   assert(ret._id, "serialization currently assumes there is a prototype in data[] to load")
   ret.proto = nil
   setmetatable(ret, {})
   return ret
end

function object.deserialize(self, _type, _id)
   if self._type and self._id then
      _type = self._type
      _id = self._id
      self._type = nil
      self._id = nil
   end
   assert(_type)
   assert(_id)
   local proto = data[_type][_id]
   if not proto then
      error("no proto " .. tostring(_type) .. " " .. tostring(_id))
   end
   local iface = data[_type]:interface()
   assert(iface)
   setmetatable(self, { __index = object.__index, __proto = proto, __iface = iface })
end

return object
