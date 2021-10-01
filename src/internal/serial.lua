local env = require("internal.env")
local binser = require("thirdparty.binser")

-- Serialization support for class tables

local function class_serialize(klass)
   assert(klass.__require_path, tostring(klass) .. " missing require path")

   return {
      serial_id = klass.__serial_id,
      require_path = klass.__require_path,
      mod_id = klass.__mod_id,
      mod_version = klass.__mod_version
   }
end

local function class_deserialize(t)
   local klass = env.get_class_for_serial_id(t.serial_id)
   if klass == nil then
      klass = require(t.require_path)
   end
   return klass
end

if not binser.hasRegistry("class") then
   binser.register(class.class_mt, "class", class_serialize, class_deserialize)
end

if not binser.hasRegistry("interface") then
   binser.register(class.interface_mt, "interface", class_serialize, class_deserialize)
end
