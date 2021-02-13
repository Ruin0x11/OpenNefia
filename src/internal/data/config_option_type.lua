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

         default = false,

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

         default = function(option)
            return option.min_value or 0
         end,

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

         default = function(option)
            return option.min_value or 0
         end,

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

         default = function(option)
            local choices = option.choices
            if type(choices) == "function" then
               choices = choices()
               if not type(choices) == "table" then
                  error(("Choices returned from callback must be table, got: %s"):format(tostring(choices)))
               end
            end
            print(inspect(choices))
            return choices[1]
         end,

         validate = function(option, value)
            local choices = option.choices
            if type(choices) == "function" then
               choices = choices()
               if not type(choices) == "table" then
                  return false, ("Choices returned from callback must be table, got: %s"):format(tostring(choices))
               end
            end
            if not table.set(choices)[value] then
               return false, ("value '%s' is not contained in choices set '%s'"):format(value, inspect(choices, {newline=" "}))
            end
            return true
         end,
      },
      {
         _id = "string",

         fields = { max_length = "integer" },
         widget = "api.gui.menu.config.item.ConfigItemStringWidget",

         default = "",

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
            local I18N = require("api.I18N")
            local sort = function(a, b) return a < b end
            local proto = {
               _id = proto._id,
               formatter = function(_id, value)
                  return I18N.get("ui.language." .. value)
               end,
               choices = data[proto.data_type]:iter():extract("_id"):into_sorted(sort):to_list()
            }
            return ConfigItemEnumWidget:new(proto)
         end,

         default = function(option)
            return data[option.data_type]:iter():nth(1)._id
         end,

         validate = function(option, value)
            local ok, err = typecheck(value, "string")
            if not ok then
               return false, err
            end

            local proxy = data[option.data_type]
            local len = proxy:iter():length()
            if len == 0 then
               return false, ("Data type %s has no entries"):format(option.data_type)
            end

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