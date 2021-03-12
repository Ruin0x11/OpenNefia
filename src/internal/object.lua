local env = require("internal.env")
local data = require("internal.data")
local binser = require("thirdparty.binser")

local object = {}

-- Modification of penlight's algorithm to ignore class fields
local function cycle_aware_copy(t, cache)
   if type(t) ~= 'table' then return t end
   if cache[t] then return cache[t] end
   local res = {}
   cache[t] = res
   local mt = getmetatable(t)
   for k,v in pairs(t) do
      -- TODO: standardize no-save fields
      k = cycle_aware_copy(k, cache)
      v = cycle_aware_copy(v, cache)
      res[k] = v
   end
   setmetatable(res,mt)
   return res
end

-- ignores location field only, unlike Object.make_prototype
function object.make_prototype(obj)
   local _type = obj.proto._type
   local _id = obj.proto._id

   local copy = cycle_aware_copy(obj, {})
   setmetatable(copy, nil)

   -- for deserialization, removed afterward
   copy._type = _type
   copy._id = _id

   return copy
end

function object.__index(t, k)
   local mt = getmetatable(t)

   if k == "__iface" then
      return mt.__iface
   end
   if k == "__mt" then
      return env.get_require_path(mt.__iface)
   end
   if k == "_id" then
      return mt._id
   end
   if k == "_type" then
      return mt._type
   end
   if k == "uid" then
      return mt.uid
   end
   if k == "proto" then
      return data[mt._type]:ensure(mt._id)
   end
   if k == "x" then
      return mt.x
   end
   if k == "y" then
      return mt.y
   end
   if k == "location" then
      return mt.location
   end

   local v = rawget(t, k)
   if v ~= nil then
      return v
   end

   return mt.__iface[k]
end

function object.__newindex(t, k, v)
   if k == "__iface"
      or k == "__mt"
      or k == "_id"
      or k == "_type"
      or k == "uid"
      or k == "proto"
      or k == "x"
      or k == "y"
      or k == "location"
   then
      error(("'%s' is a reserved field name on map objects."):format(k))
   end

   local mt = getmetatable(t)
   if mt.__iface[k] then
      error(("Tried to overwrite a field on interface '%s' named '%s'"):format(mt.__iface, k))
   end

   rawset(t, k, v)
end

function object.serialize(self)
   local ret = object.make_prototype(self)
   assert(ret._id, "serialization currently assumes there is a prototype in data[] to load")

   -- for deserialization, removed afterward
   ret.x = self.x
   ret.y = self.y
   ret.uid = self.uid
   assert(ret.location == nil)

   return ret
end

-- This is a hack so we can ensure everything that gets deserialized will have
-- 'base.on_object_instantiated' called on it, no matter if it's in the map or
-- inside a container in `save`.
local _FOUND_OBJECTS = {}

function object.deserialize(self, _type, _id)
   if self._type and self._id then
      _type = self._type
      _id = self._id
      self._type = nil
      self._id = nil
   end

   local x = 0
   local y = 0
   local uid = nil

   -- Get some fields that the serializer saved for us and restore them.
   -- Afterward they are removed, as they are reserved for internal use.
   assert(self.location == nil)
   if self.x or self.y then
      assert(self.x and self.y, "Both x and y must be specified")
      x = self.x
      y = self.y
      self.x = nil
      self.y = nil
   end
   if self.uid then
      uid = self.uid
      self.uid = nil
   end

   assert(type(_type) == "string")
   assert(type(_id) == "string")
   local proto = data[_type][_id]
   if not proto then
      error("no proto " .. tostring(_type) .. " " .. tostring(_id))
   end
   local iface = data[_type]:interface()
   assert(iface)

   local mt = {
      _id = _id,
      _type = _type,
      uid = uid,

      -- for map objects. these must always be non-nil.
      x = x,
      y = y,

      -- to be set by pool:deserialize()
      location = nil,

      __id = "object",
      __index = object.__index,
      __newindex = object.__newindex,
      __iface = iface,
      __tostring = object.__tostring,
   }

   local obj = setmetatable(self, mt)
   _FOUND_OBJECTS[#_FOUND_OBJECTS+1] = obj

   return obj
end

function object.clear_last_deserialized_objects()
   _FOUND_OBJECTS = {}
end

function object.get_last_deserialized_objects()
   local result = _FOUND_OBJECTS
   _FOUND_OBJECTS = {}
   return result
end

function object:__tostring()
   local addr = string.tostring_raw(self):gsub("^table: (.*)", "%1")
   return ("<object ('%s', uid %d) %s>"):format(self._type, self.uid, addr)
end

if not binser.hasRegistry("object") then
   binser.register("object", "object", object.serialize, object.deserialize)
end

return object
