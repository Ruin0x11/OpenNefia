local data = require("internal.data")

local Config = {}

function Config.verify_option(value, option)
   if option.optional and value == nil then
      return true
   end

   local ty = option.type
   if not string.find(ty, "%.") then
      ty = "base." .. ty
   end
   local config_option_type = data["base.config_option_type"][ty]
   if config_option_type == nil then
      return false, ("invalid option type '%s'"):format(ty)
   end

   return config_option_type.validate(option, value)
end

function Config.get_default_option(option)
   local default = option.default

   if option.default == nil then
      -- If this option does not specify a default, fall back to the default for
      -- this type overall. For example, numbers should return 0, strings should
      -- return "", enums should return the first choice in the list, etc.
      local ty = option.type
      if not string.find(ty, "%.") then
         ty = "base." .. ty
      end
      local config_option_type = data["base.config_option_type"]:ensure(ty)
      default = config_option_type.default
      print(default)
      if type(default) == "function" then
         default = default(option)
      end

      if default == nil then
         return
      end
   end

   local ok, err = Config.verify_option(default, option)
   if not ok then
      return false, ("Invalid default for config option '%s': %s"):format(option._id, err)
   end

   if type(option.default) == "table" then
      return table.deepcopy(default)
   end

   return true, default
end

return Config
