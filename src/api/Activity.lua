local Object = require("api.Object")
local data = require("internal.data")

local Activity = {}

function Activity.create(id, params)
   local obj = Object.generate_from("base.activity", id)
   Object.finalize(obj)

   obj.params = {}
   local activity = data["base.activity"]:ensure(id)
   for property, ty in pairs(activity.params or {}) do
      local value = params[property]
      -- everything is implicitly optional for now, until we get a better
      -- typechecker
      if value ~= nil and type(value) ~= ty then
         error(("Activity '%s' requires parameter '%s' of type %s, got '%s'"):format(id, property, ty, value))
      end
      obj.params[property] = value
   end

   return obj
end

return Activity
