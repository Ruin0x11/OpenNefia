local ModExtTable = require("api.ModExtTable")

local IModDataHolder = class.interface("IModDataHolder", { get_mod_data = "function" })

function IModDataHolder:init()
   self._mod_data = ModExtTable:new()
end

function IModDataHolder:get_mod_data(mod_id)
   return self._mod_data:get_mod_data(mod_id)
end

return IModDataHolder
