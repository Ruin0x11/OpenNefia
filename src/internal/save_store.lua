local env = require ("internal.env")

local SaveFs = require("api.SaveFs")

if env.is_hotloading() then
   return "no_hotload"
end

local save_data = {}

local save_store = {}

function save_store.for_mod(mod_id)
   -- if not mod.is_mod_loaded(mod_id) then
   --    error(string.format("Mod %s is not loaded.", mod_id))
   -- end
   if not save_data[mod_id] then
      save_data[mod_id] = {}
   end

   return save_data[mod_id]
end

function save_store.clear()
   table.replace_with(save_data, {})
end

function save_store.save()
   return SaveFs.write("global", save_data, "temp")
end

function save_store.load()
   local success, from_disk = SaveFs.read("global", "temp")
   if not success then
      return false, from_disk
   end

   for k, v in pairs(from_disk) do
      save_data[k] = save_data[k] or {}
      table.replace_with(save_data[k], v)
   end

   return true, from_disk
end

function save_store.proxy()
   return setmetatable({}, {
         __index = function(_, k) return save_store.for_mod(k) end,
         __newindex = function() end
   })
end

return save_store
