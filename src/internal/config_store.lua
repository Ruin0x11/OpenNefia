local env = require ("internal.env")
local config_holder = require("internal.config_holder")
local Log = require("api.Log")

local SaveFs = require("api.SaveFs")

if env.is_hotloading() then
   return "no_hotload"
end

local config_data = {}

local config_store = {}

function config_store.for_mod(mod_id)
   if not config_data[mod_id] then
      local mod = require("internal.mod")
      if not mod.is_loaded(mod_id) then
         error(string.format("Mod %s is not loaded.", mod_id))
      end
      config_data[mod_id] = config_holder:new(mod_id)
   end

   return config_data[mod_id]
end

function config_store.clear()
   table.replace_with(config_data, {})
end

function config_store.trigger_on_changed()
   local data = require("internal.data")
   for mod_id, store in pairs(config_data) do
      for k, _ in pairs(store._data) do
         local option = data["base.config_option"]:ensure(mod_id .. "." .. k)
         if option.on_changed then
            Log.debug("Running on_changed callback: " .. k)
            option.on_changed(store[k], true)
         end
      end
   end
end

function config_store.save()
   Log.info("Saving config.")
   return SaveFs.write("config", config_data, "global")
end

function config_store.load()
   Log.info("Loading config.")
   local success, from_disk = SaveFs.read("config", "global")
   if not success then
      return false, from_disk
   end

   for mod_id, v in pairs(from_disk) do
      config_data[mod_id] = v
   end

   return true, from_disk
end

function config_store.proxy()
   return setmetatable({}, {
         __index = function(_, k) return config_store.for_mod(k) end,
         __newindex = function() end,
         __completions = function() return table.keys(config_data) end
   })
end

return config_store
