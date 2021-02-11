local data = require("internal.data")

local function typecheck(value, ty)
   local our_ty = type(value)
   if our_ty ~= ty then
      return false, ("expected value of type '%s', got '%s'"):format(ty, our_ty)
   end
   return true, nil
end

data:add_multi(
   "base.config_option_type",
   {
      {
         _id = "boolean",

         fields = {},
         widget = "api.gui.menu.config.item.ConfigItemBooleanWidget",

         validate = function(option, value)
            local ok, err = typecheck(value, "boolean")
            if not ok then
               return false, err
            end
            return true
         end,
      },
      {
         _id = "number",

         fields = { min_value = "number", max_value = "number" },
         widget = "api.gui.menu.config.item.ConfigItemNumberWidget",

         validate = function(option, value)
            local ok, err = typecheck(value, "number")
            if not ok then
               return false, err
            end

            if option.min_value or option.max_value then
               if not (option.min_value and option.max_value) then
                  return false, ("Both 'min_value' and 'max_value' must be specified if one is declared (got: %s, %s)")
                     :format(option.min_value, option.max_value)
               end
               if type(option.min_value) ~= "number" or type(option.max_value) ~= "number" then
                  return false, ("'min_value' and 'max_value' must both be numbers (got: %s, %s)")
                     :format(option.min_value, option.max_value)
               end
               if option.min_value > option.max_value then
                  return false, ("'min_value' must be less than max_value (got: %d, %d)")
                     :format(option.min_value, option.max_value)
               end
            end

            return true
         end,
      },
      {
         _id = "integer",

         fields = { min_value = "integer", max_value = "integer" },
         widget = "api.gui.menu.config.item.ConfigItemIntegerWidget",

         validate = function(option, value)
            if math.type(value) ~= "integer" then
               return false, ("expected integer, got %s"):format(math.type(value))
            end

            if option.min_value or option.max_value then
               if not (option.min_value and option.max_value) then
                  return false, ("Both 'min_value' and 'max_value' must be specified if one is declared (got: %s, %s)")
                     :format(option.min_value, option.max_value)
               end
               if math.type(option.min_value) ~= "integer" or math.type(option.max_value) ~= "integer" then
                  return false, ("'min_value' and 'max_value' must both be integers (got: %s, %s)")
                     :format(option.min_value, option.max_value)
               end
               if option.min_value > option.max_value then
                  return false, ("'min_value' must be less than max_value (got: %d, %d)")
                     :format(option.min_value, option.max_value)
               end
            end

            return true
         end

      },
      {
         _id = "enum",

         fields = { choices = "table" },
         widget = "api.gui.menu.config.item.ConfigItemEnumWidget",

         validate = function(option, value)
            if not table.set(option.choices)[value] then
               return false, ("value '%s' is not contained in choices set '%s'"):format(value, inspect(option.choices, {newline=" "}))
            end
            return true
         end,
      },
      {
         _id = "string",

         fields = { max_length = "integer" },
         widget = "api.gui.menu.config.item.ConfigItemStringWidget",

         validate = function(option, value)
            local ok, err = typecheck(value, "string")
            if not ok then
               return false, err
            end
            return true
         end
      },
      {
         _id = "table",

         fields = {},
         widget = "api.gui.menu.config.item.ConfigItemNullWidget",

         validate = function(option, value)
            local ok, err = typecheck(value, "table")
            if not ok then
               return false, err
            end
            return true
         end
      },
      {
         _id = "data_id",

         fields = {},
         widget = function(proto)
            local ConfigItemEnumWidget = require("api.gui.menu.config.item.ConfigItemEnumWidget")
            return ConfigItemEnumWidget:new(proto)
         end,

         validate = function(option, value)
            local ok, err = typecheck(value, "string")
            if not ok then
               return false, err
            end

            local proxy = data[option.data_type]
            ok, err = pcall(proxy.ensure, proxy, value)
            if not ok then
               return false, err
            end

            return true
         end
      },
      {
         _id = "any",

         fields = {},
         widget = "api.gui.menu.config.item.ConfigItemNullWidget",

         validate = function(option, value)
            return true
         end
      }
   }
)
