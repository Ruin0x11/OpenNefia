local Log = require("api.Log")
local Config = require("api.Config")
local data = require("internal.data")
local ISerializable = require("api.ISerializable")

local config_holder = class.class("config_holder", ISerializable)
config_holder.__serial_id = "63e61cda-2a0e-4bc9-bf35-525fc95a719a"
config_holder.__serial_opts = { load_type = "deferred" }

function config_holder:init(mod_id)
   assert(mod_id, "No mod ID provided")
   rawset(self, "_mod_id", mod_id)
   rawset(self, "_data", {})
end

function config_holder:__index(k)
   local exist = rawget(config_holder, k)
   if exist then return exist end

   local option = data["base.config_option"][self._mod_id .. "." .. k]
   if option == nil then
      error(("No config option '%s' exists for mod '%s'."):format(k, self._mod_id))
   end

   if self._data[k] == nil and not option.optional then
      local ok, default = Config.get_default_option(option)
      if not ok then
         error(default)
      end

      self._data[k] = default
   end

   return self._data[k]
end

function config_holder:__newindex(k, v)
   local option = data["base.config_option"][self._mod_id .. "." .. k]
   if option == nil then
      error(("No config option '%s' exists for mod '%s'."):format(k, self._mod_id))
   end

   local ok, err = Config.verify_option(v, option)
   if not ok then
      error(("Invalid value for config option '%s': %s"):format(option._id, err))
   end

   self._data[k] = v

   if option.on_changed then
      option.on_changed(v)
   end
end

function config_holder.deserialize(raw)
   local dead = {}

   for k, v in pairs(raw._data) do
      local id = raw._mod_id .. "." .. k
      local option = data["base.config_option"][id]
      if not option then
         Log.warn("Missing config option '%s' in engine, but was saved", id)
         dead[#dead+1] = k
      else
         local ok, err = Config.verify_option(v, option)
         if not ok then
            Log.warn("Invalid config option '%s' in engine, but was saved: %s", id, err)
            dead[#dead+1] = k
         end
      end
   end
   table.remove_keys(raw._data, dead)

   return raw
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
      :into_sorted()
      :foldl(concat)

   options = options or " (none)"

   return ("config %s:%s"):format(self._mod_id, options)
end

function config_holder:__completions()
   local format = function(o)
      return o._id:gsub("([a-zA-Z0-9_]+)%.([a-zA-Z0-9_]+)", "%2")
   end

   local Env = require("api.Env")
   return data["base.config_option"]:iter()
      :filter(Env.mod_filter(self._mod_id))
      :map(format)
      :into_sorted()
      :to_list()
end

return config_holder
