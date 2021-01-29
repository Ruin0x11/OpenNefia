local env = require ("internal.env")
local mod = require("internal.mod")
local config_holder = require("internal.config_holder")

local SaveFs = require("api.SaveFs")

if env.is_hotloading() then
   return "no_hotload"
end

local config_data = {}

local config_store = {}

function config_store.for_mod(mod_id)
   -- if not mod.is_mod_loaded(mod_id) then
   --    error(string.format("Mod %s is not loaded.", mod_id))
   -- end
   if not config_data[mod_id] then
      config_data[mod_id] = {}
   end

   return config_data[mod_id]
end

function config_store.clear()
   table.replace_with(config_data, {})
end

function config_store.save()
   return SaveFs.write("config", config_data)
end

function config_store.load()
   local success, from_disk = SaveFs.read("config")
   if not success then
      return false, from_disk
   end

   for mod_id, v in pairs(from_disk) do
      config_data[mod_id] = v
   end

   return true, from_disk
end

function config_store.initialize()
   for _, mod in mod.iter_loaded() do
      config_data[mod.id] = config_holder:new(mod.id)
   end
end

function config_store.proxy()
   return setmetatable({}, {
         __index = function(_, k) return config_store.for_mod(k) end,
         __newindex = function() end
   })
end

return config_store
