local Map = require("api.Map")
local env = require("internal.env")

local Codegen = {}

function Codegen.loadstring(str)
   local mod_name = env.find_calling_mod()

   -- TODO: cache this somewhere.
   local mod_env = env.generate_sandbox(mod_name, true)

   local f, err = loadstring(str)
   if not f then
      return nil, err
   end

   assert(mod_env.require ~= require)
   setfenv(f, mod_env)

   return f
end

function Codegen.generate_object_getter(klass, name, _type)

   local private = "_" .. name
   klass["get_" .. name] = function(self, map)
      map = map or Map.current()
      local uid = self[private]
      if not map:has_object_of_type(_type, uid) then
         return nil
      end

      return map:get_object(uid)
   end
   klass["set_" .. name] = function(self, v, map)
      map = map or Map.current()
      if not map:has_object(v) then
         error("object must be in provided map")
      end
      if not v._type == _type then
         error(string.format("field '%s' must have type '%s' (got: '%s')", name, _type, v._type))
      end
      self[private] = v.uid
   end
end

return Codegen
