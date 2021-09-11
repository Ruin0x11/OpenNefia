local Object = require("api.Object")

local Activity = {}

function Activity.create(_id, params)
   local obj = Object.generate_from("base.activity", _id)
   Object.finalize(obj)

   obj.params = Object.copy_params(obj.proto.params, params, "base.activity", _id)

   return obj
end

return Activity
