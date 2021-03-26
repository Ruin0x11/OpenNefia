local Env = require("api.Env")

local ModExtTable = class.class("ModExtTable")

function ModExtTable:init()
   self._store = {}
end

function ModExtTable:get_mod_data(mod_id)
   assert(type(mod_id) == "string", "Mod ID must be provided.")

   if self._store[mod_id] then
      return self._store[mod_id]
   end

   if not Env.is_mod_loaded(mod_id) then
      error(("Mod '%s' is not loaded."):format(mod_id))
   end

   self._store[mod_id] = {}
   return self._store[mod_id]
end

function ModExtTable:iter()
   return next, self._store, nil
end

function ModExtTable:serialize()
   local dead = {}
   for mod_id, store in pairs(self._store) do
      if next(store) == nil then
         dead[#dead+1] = mod_id
      end
   end
   table.remove_keys(self._store, dead)
end

function ModExtTable:deserialize()
end

function ModExtTable:compare(other)
   local found = {}

   for mod_id, _ in self:iter() do
      found[mod_id] = false
   end

   for mod_id, their_store in other:iter() do
      if not found[mod_id] then
         found[mod_id] = true
         local my_store = self._store[mod_id]
         if not table.deepcompare(my_store, their_store) then
            return false, mod_id
         end
      else
         return false, mod_id
      end
   end

   for mod_id, was_found in pairs(found) do
      if was_found == false then
         return false, mod_id
      end
   end

   return true
end

return ModExtTable
