-- Initialize save data for a new save game here, or remove this file if it's
-- unnecessary.
local Event = require("api.Event")

local function init_save()
   local s = save.sokoban
   -- s.high_score = 0
   -- s.my_data = { ... }
end

Event.register("base.on_init_save", "Init save (sokoban)", init_save)
