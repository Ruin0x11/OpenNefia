local function typecheck(value, ty)
   local our_ty = type(value)
   if our_ty ~= ty then
      return false, ("expected value of type '%s', got '%s'"):format(ty, our_ty)
   end
   return true, nil
end

data:add {
   _type = "base.config_option_type",
   _id = "color",

   fields = {},
   widget = "mod.extra_config_options.api.gui.ConfigItemColorWidget",

   validate = function(option, value)
      local ok, err = typecheck(value, "table")
      if not ok then
         return false, err
      end

      if type(value[1]) ~= "number"
         or type(value[2]) ~= "number"
         or type(value[3]) ~= "number"
         or (value[4] ~= nil and type(value[4]) ~= "number")
      then
         return false, "Value must be a table of 3 or 4 numbers."
      end

      local filter = function(i) return i < 0 or i > 255 end

      if fun.iter(value):any(filter) then
         return false, "Values must be between 0 and 255."
      end

      return true
   end,
}

data:add {
   _type = "base.config_option_type",
   _id = "text",

   fields = {},
   widget = "mod.extra_config_options.api.gui.ConfigItemTextWidget",

   validate = function(option, value)
      return typecheck(value, "string")
   end,
}
