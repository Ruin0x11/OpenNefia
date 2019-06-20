local IMapObject = require("api.IMapObject")

local MapObject = {}

local uids = require("internal.global.uids")

function MapObject.generate_from(_type, id, uid_tracker)
   return MapObject.generate(data[_type][id], uid_tracker)
end

function MapObject.generate(proto, uid_tracker)
   uid_tracker = uid_tracker or uids

   local uid = uid_tracker:get_next_and_increment()

   local tbl = {
      temp = {}
   }

   if not is_an(IMapObject, proto) then
      setmetatable(proto, IMapObject)
   end

   local data = setmetatable(tbl, { __index = proto })

   data:calc("on_build")

   rawset(data, "uid", uid)

   return data
end

return MapObject
