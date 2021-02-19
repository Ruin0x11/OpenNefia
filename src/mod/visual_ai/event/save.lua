-- Initialize save data for a new save game here, or remove this file if it's
-- unnecessary.
local Event = require("api.Event")

local function init_save()
   local s = save.visual_ai
   s.editing_chara = nil
end

Event.register("base.on_init_save", "Init save (visual_ai)", init_save)
