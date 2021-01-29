local data = require("internal.data")
local Env = require("api.Env")
local Log = require("api.Log")

local config_holder = class.class("config_holder")

function config_holder:init(mod_id)
   assert(mod_id, "No mod ID provided")
   rawset(self, "_mod_id", mod_id)
   rawset(self, "_data", {})
end

local function typecheck(value, ty)
   local our_ty = type(value)
   if our_ty ~= ty then
      return false, ("expected value of type '%s', got '%s'"):format(ty, our_ty)
   end
   return true, nil
end

local function verify_option(value, option)
   if option.type == "boolean" then
      local ok, err = typecheck(value, "boolean")
      if not ok then
         return false, err
      end
      return true
   elseif option.type == "number" then
      local ok, err = typecheck(value, "number")
      if not ok then
         return false, err
      end
      return true
   elseif option.type == "integer" then
      if math.type(value) ~= "integer" then
         return false, ("expected integer, got %s"):format(math.type(value))
      end
      return true
   elseif option.type == "enum" then
      if not table.set(option.choices)[value] then
         return false, ("value '%s' is not contained in choices set '%s'"):format(value, inspect(option.choices, {newline=" "}))
      end
      return true
   elseif option.type == "string" then
      local ok, err = typecheck(value, "string")
      if not ok then
         return false, err
      end
      return true
   elseif option.type == "data_id" then
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
   elseif option.type == "any" then
      return true
   else
      return false, ("invalid option type '%s'"):format(option.type)
   end
end

local function set_default_option(option)
   if option.default == nil then
      return
   end

   local ok, err = verify_option(option.default, option)
   if not ok then
      error(("Invalid default for config option '%s': %s"):format(option._id, err))
   end

   return option.default
end

function config_holder:__index(k)
   local exist = rawget(config_holder, k)
   if exist then return exist end

   local option = data["base.config_option"][self._mod_id .. "." .. k]
   if option == nil then
      error(("No config option '%s' exists for mod '%s'."):format(k, self._mod_id))
   end

   if self._data[k] == nil then
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
      local name = o._id:gsub("([a-zA-Z0-9]+)%.([a-zA-Z0-9]+)", "%2")
      local value = self[name]
      return ("%s = %s"):format(name, tostring(value))
   end
   local concat = function(acc, s) return (acc and (acc .. "\n    ") or "\n    ") .. s end

   local options = data["base.config_option"]:iter()
      :filter(Env.mod_filter(self._mod_id))
      :map(format)
      :foldl(concat)

   options = options or " (none)"

      return ("config %s:%s"):format(self._mod_id, options)
end

return config_holder
