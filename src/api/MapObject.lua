local IMapObject = require("api.IMapObject")

local MapObject = {}

local uids = require("internal.global.uids")

function MapObject.generate_from(_type, id, uid_tracker)
   return MapObject.generate(data[_type][id], uid_tracker)
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

   local tbl = {
      temp = {},
      proto = proto
   }

   local data = setmetatable(tbl, { __index = makeindex(proto) })

   rawset(data, "uid", uid)
   data.x = 0
   data.y = 0

   assert_is_an(IMapObject, data)

   data:build()

   return data
end

return MapObject
