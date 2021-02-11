local Log = require("api.Log")

local data = require("internal.data")

local config_holder = class.class("config_holder")

function config_holder:init(mod_id)
   assert(mod_id, "No mod ID provided")
   rawset(self, "_mod_id", mod_id)
   rawset(self, "_data", {})
end

local function verify_option(value, option)
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

local function set_default_option(option)
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

   local ok, err = verify_option(default, option)
   if not ok then
      error(("Invalid default for config option '%s': %s"):format(option._id, err))
   end

   if type(option.default) == "table" then
      return table.deepcopy(default)
   end

   return default
end

function config_holder:__index(k)
   local exist = rawget(config_holder, k)
   if exist then return exist end

   local option = data["base.config_option"][self._mod_id .. "." .. k]
   if option == nil then
      error(("No config option '%s' exists for mod '%s'."):format(k, self._mod_id))
   end

   if self._data[k] == nil and not option.optional then
      self._data[k] = set_default_option(option)
   end

   return self._data[k]
end

function config_holder:__newindex(k, v)
   local option = data["base.config_option"][self._mod_id .. "." .. k]
   if option == nil then
      error(("No config option '%s' exists for mod '%s'."):format(k, self._mod_id))
   end

   local ok, err = verify_option(v, option)
   if not ok then
      error(("Invalid value for config option '%s': %s"):format(option._id, err))
   end

   self._data[k] = v

   if option.on_changed then
      option.on_changed(v)
   end
end

function config_holder:serialize()
end

function config_holder:deserialize()
   local dead = {}
   for k, v in pairs(self._data) do
      local id = self._mod_id .. "." .. k
      local option = data["base.config_option"][id]
      if not option then
         Log.warn("Missing config option '%s' in engine, but was saved", id)
         dead[#dead+1] = k
      else
         local ok, err = verify_option(v, option)
         if not ok then
            Log.warn("Invalid config option '%s' in engine, but was saved: %s", id, err)
            dead[#dead+1] = k
         end
      end
   end
   table.remove_keys(self._data, dead)
end

function config_holder:__inspect()
   local format = function(o)
      local name = o._id:gsub("([a-zA-Z0-9_]+)%.([a-zA-Z0-9_]+)", "%2")
      local value = self[name]
      return ("%s = %s"):format(name, inspect(value))
   end
   local concat = function(acc, s) return (acc and (acc .. "\n    ") or "\n    ") .. s end

   local Env = require("api.Env")
   local options = data["base.config_option"]:iter()
      :filter(Env.mod_filter(self._mod_id))
      :map(format)
      :foldl(concat)

   options = options or " (none)"

   return ("config %s:%s"):format(self._mod_id, options)
end

function config_holder:__completions()
   return table.keys(self._data)
end

return config_holder
