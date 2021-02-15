-- Initialize save data for a new save game here, or remove this file if it's
-- unnecessary.

local function init_save()
   local s = save.visual_ai
   -- s.high_score = 0
   -- s.my_data = { ... }
end

Event.register("base.on_init_save", "Init save (visual_ai)", init_save)
