local nbt = require("thirdparty.nbt")
local ILocation = require("api.ILocation")

local nbt_serializer = class.class("nbt_serializer")

function nbt_serializer:init()
   self.next_location_index = 0
   self.known_locations = {}
   self.seen_locations = {}
end

function nbt_serializer:new_map_object_ref(obj, name)
   local values = {}

   if obj == nil then
   else
      assert(obj._id and obj._type)
      if obj.location == nil then
         values.obj = self:new_map_object_compound(obj, name)
      else
         class.assert_is_an(ILocation, obj.location)
         local idx = self.known_locations[obj.location]
         if not idx then
            idx = self.next_location_index
            self.known_locations[obj.location] = idx
            self.next_location_index = self.next_location_index + 1
         end
         values.loc = self.new_integer(idx, "loc")
         values.uid = self:new_integer(obj.uid, "uid")
      end
   end

   return self:new_compound(values, name)
end

function nbt_serializer:new_compound(values, name)
   return nbt.newCompound(values, name)
end

function nbt_serializer:new_integer(value, name)
   return nbt.newInt(value, name)
end

function nbt_serializer:new_boolean(value, name)
   return nbt.newBoolean(value, name)
end

function nbt_serializer:new_class_compound(value, name)
   return nbt.newClassCompound(value, name)
end

function nbt_serializer:new_map_object_compound(value, name)
   return nbt.newMapObjectCompound(value, name)
end

-- Guarantee by the end of the serialization pass that map object references
-- with locations outside the overarching serialized object will be removed.
--
-- If this property holds, then that means that we can assume that every
-- location ID that gets serialized is valid. Which means that we will not have
-- to keep extra state when deserializing, as we can replace the weak reference
-- with the full copy of the object when it's first encountered. Its location
-- will be deserialized later.

return nbt_serializer
