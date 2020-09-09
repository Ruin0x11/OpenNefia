local Env = require("api.Env")
local IModDataHolder = require("api.IModDataHolder")

local ModExtTable = class.class("ModExtTable", IModDataHolder)

function ModExtTable:init()
   self._store = {}
end

function ModExtTable:get_mod_data(mod_id)
   if self._store[mod_id] then
      return self._store[mod_id]
   end

   if not Env.is_mod_loaded(mod_id) then
      error(("Mod '%s' is not loaded."):format(mod_id))
   end

   self._store[mod_id] = {}
   return self._store[mod_id]
end

return ModExtTable
