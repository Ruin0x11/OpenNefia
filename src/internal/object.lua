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
      -- NOTE: preserves the UID for now.
      if k ~= "location" then
         k = cycle_aware_copy(k, cache)
         v = cycle_aware_copy(v, cache)
         res[k] = v
      end
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
   if k == "__iface" then
      local mt = getmetatable(t)
      return mt.__iface
   end
   if k == "__mt" then
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
   -- v = mt.__proto[k]
   -- if v ~= nil then
   --    return v
   -- end

   return mt.__iface[k]
end

local function extract_functions(instance, serial, proto, cache)
   if type(proto) ~= "table" then
      return
   end

   -- protect against recursive tables
   if cache[instance] or cache[proto] then
      return
   end
   cache[instance] = true
   cache[proto] = true

   for k, v in pairs(instance) do
      if type(k) == "string" then
         if type(v) == "function" and proto[k] == v then
            serial[k] = "copy_from_proto"
         elseif type(v) == "table" and type(instance) == "table" then
            serial[k] = {}
            extract_functions(serial[k], v, proto[k], cache)
         end
      end
   end
end

local function copy_functions(instance, serial, proto, cache)
   if type(proto) ~= "table" then
      return
   end

   -- protect against recursive tables
   if cache[instance] or cache[proto] then
      return
   end
   cache[instance] = true
   cache[proto] = true

   for k, v in pairs(serial) do
      if v == "copy_from_proto" then
         instance[k] = proto[k]
      elseif type(v) == "table" and type(instance[k]) == "table" then
         copy_functions(instance[k], v, proto[k], cache)
      end
   end
end

function object.serialize(self)
   local proto = self.proto

   local ret = object.make_prototype(self)
   assert(ret._id, "serialization currently assumes there is a prototype in data[] to load")

   local serial = {}
   extract_functions(self, serial, proto, {})
   ret.__serial = serial
   return ret
end

function object.deserialize(self, _type, _id)
   if self._type and self._id then
      _type = self._type
      _id = self._id
   end
   assert(type(_type) == "string")
   assert(type(_id) == "string")
   local proto = data[_type][_id]
   if not proto then
      error("no proto " .. tostring(_type) .. " " .. tostring(_id))
   end
   local iface = data[_type]:interface()
   assert(iface)

   self._type = _type
   self._id = _id

   -- functions on the prototype table are not serialized, so they
   -- must be copied from the prototype to the instance on
   -- deserialization if they were unchanged from the prototype's
   -- version on save.
   local serial = self.__serial
   if serial then
      self.__serial = nil
      copy_functions(self, serial, proto, {})
   end

   setmetatable(self,
                {
                   __id = "object",
                   __index = object.__index,
                   __proto = proto,
                   __iface = iface,
                   __tostring = function(t)
                      local addr = string.gsub(string.tostring_raw(self), "^table: (.*)", "%1")
                      return ("<object ('%s', uid %d) %s>"):format(t._type, t.uid, addr)
                   end,
                   __inspect = function(t)
                      local n = {}
                      for k, v in pairs(t) do
                         if not (type(k) == "string" and string.match(k, "^__")) then
                            n[k] = v
                         end
                      end
                      return inspect(n)
                   end
   })
   return self
end

if not binser.hasRegistry("object") then
   binser.register("object", "object", object.serialize, object.deserialize)
end

return object
