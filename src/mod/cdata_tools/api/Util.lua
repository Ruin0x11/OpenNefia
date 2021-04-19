local Sjis = require("mod.extlibs.api.Sjis")
local CodeGenerator = require("api.CodeGenerator")
local Log = require("api.Log")

local Util = {}

function Util.filter_spec(to)
   return {
      to = to,
      type = "string",
      cb = function(filter)
         return fun.iter(string.split(filter, "/")):filter(function(s) return s ~= "" end):to_list()
      end
   }
end

function Util.get_number(custom_file, key, default)
   default = default or 0

   local value = custom_file.options[key]
   if value == nil then
      return nil
   end

   value = tonumber(value)
   if value == default then
      return nil
   end

   return value
end

function Util.get_string(custom_file, key, default)
   default = default or 0

   local value = custom_file.options[key]
   if value == nil then
      return nil
   end

   value = Sjis.to_utf8(value)
   if value == default then
      return nil
   end

   return value
end

function Util.get_localized_string(custom_file, key, is_jp)
   local value = Util.get_string(custom_file, key)
   if value then
      local split = string.split(value, ",")
      if is_jp then
         return split[2]
      else
         return split[1]
      end
   end

   return nil
end

function Util.get_int_list(custom_file, key, default)
   default = default or 0

   local value = custom_file.options[key]
   if value == nil then
      return nil
   end

   value = fun.iter(string.split(value, ",")):map(tonumber):to_list()
   if table.deepcompare(value, default) then
      return nil
   end

   return value
end

function Util.is_ascii_only(str)
   for c in string.chars(str) do
      if string.byte(c) >= 128 then
         return false
      end
   end
   return true
end

function Util.apply_spec(result, spec, file_data, mod_id)
   local requires = {}

   for k, v in pairs(spec) do
      if type(v) == "function" then
         local value = Util.get_string(file_data, k, "")
         v(result, value, mod_id)
      else
         local ty = v.type or "number"
         local value
         if ty == "number" then
            local default = v.default or 0
            value = Util.get_number(file_data, k, default)
         elseif ty == "string" then
            local default = v.default or ""
            value = Util.get_string(file_data, k, default)
         elseif ty == "int_list" then
            local default = v.default or {}
            value = Util.get_int_list(file_data, k, default)
         elseif type(ty) == "table" and ty.__enum then
            local default = v.default or 0
            value = Util.get_number(file_data, k, default)
            if value then
               assert(ty:has_value(value))
            end
            value = CodeGenerator.gen_literal(("Enum.%s.%s"):format(ty.__name, ty:to_string(value)))
            requires["api.Enum"] = true
         else
            error("Unknown type " .. ty)
         end

         if value then
            if v.cb then
               value = v.cb(value, mod_id)
            end
            result[v.to] = value
         end
      end
   end

   for k, _ in pairs(file_data.options) do
      if not spec[k] then
         Log.debug("Missing key %s in spec", k)
      end
   end

   requires = table.keys(requires)
   table.sort(requires)
   return requires
end

return Util
