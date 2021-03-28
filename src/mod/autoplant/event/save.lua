-- Initialize save data for a new save game here, or remove this file if it's
-- unnecessary.
local Event = require("api.Event")

local function init_save()
   local s = save.autoplant
   s.enabled = false
end

Event.register("base.on_init_save", "Init save (autoplant)", init_save)
