local Log = require("api.Log")
local uids = require("internal.global.uids")

local MapObject = {}

function MapObject.generate_from(_type, id, uid_tracker)
   local data = require("internal.data")
   local proto = data[_type]:ensure(id)
   return MapObject.generate(proto, uid_tracker)
end

local function makeindex(proto)
   return function(t, k)
      local v = rawget(t, k)
      if v ~= nil then
         return v
      end

      return proto[k]
   end
end

function MapObject.generate(proto, uid_tracker)
   uid_tracker = uid_tracker or uids

   local uid = uid_tracker:get_next_and_increment()

   -- if the passed object was a previously instantiated one, take its
   -- proto field and merge the rest of the fields after building
   -- TODO: prefix proto as __proto since it serves a special purpose
   local used_proto = proto
   local merge_rest = false

   -- HACK: there needs to be a better way of telling "is/was this a
   -- map object instance?"
   local is_instance = used_proto.uid ~= nil

   if is_instance then
      assert(used_proto.location == nil)

      local data = require("internal.data")
      used_proto = data[used_proto._type][used_proto._id]
      merge_rest = true

      -- remove fields that shouldn't be merged into the new instance
      proto.proto = nil
      proto.uid = nil
   end

   local tbl = {
      temp = {},
      proto = used_proto
   }

   local data = setmetatable(tbl, { __index = makeindex(proto) })

   rawset(data, "uid", uid)
   data.x = 0
   data.y = 0

   data:build()

   if merge_rest then
      data = table.merge(data, proto)
   end

   return data
end

return MapObject
