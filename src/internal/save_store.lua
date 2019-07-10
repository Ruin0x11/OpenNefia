local env = require ("internal.env")

local Save = require("api.Save")

if env.is_hotloading() then
   return "no_hotload"
end

local save_data = {}

local save_store = {}

function save_store.for_mod(mod_id)
   if not save_data[mod_id] then
      save_data[mod_id] = {}
   end

   return save_data[mod_id]
end

function save_store.save()
   return Save.write("global", save_data)
end

function save_store.load()
   local success, from_disk = Save.read("global")
   if not success then
      return false, from_disk
   end

   for k, v in pairs(from_disk) do
      save_data[k] = save_data[k] or {}
      table.replace_with(save_data[k], v)
   end

   return true, from_disk
end

return save_store
