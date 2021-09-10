local Object = require("api.Object")
local data = require("internal.data")

local Activity = {}

local function copy_params(activity, params)
   local proto = data["base.activity"]:ensure(activity._id)
   local found = table.set{}

   for property, entry in pairs(proto.params or {}) do
      local value = params[property]
      local error_msg = "Invalid parameter passed for activity with ID '%d': "
      local checker
      if types.is_type_checker(entry) then
         checker = entry
      else
         checker = entry.type
         if value == nil then
            value = entry.default
            error_msg = "Invalid default parameter for activity with ID '%d': "
         end
      end
      local ok, err = types.check(value, checker)
      if not ok then
         error((error_msg):format(activity._id), err)
      end
      activity.params[property] = value
   end

   if table.count(found) ~= table.count(params) then
      for k, v in pairs(params) do
         if not proto.params[k] then
            error(("Activity '%s' does not accept parameter '%s'"):format(activity._id, k))
         end
      end
   end
end

function Activity.create(id, params)
   local obj = Object.generate_from("base.activity", id)
   Object.finalize(obj)

   obj.params = {}
   if params then
      copy_params(obj, params)
   end

   return obj
end

return Activity
