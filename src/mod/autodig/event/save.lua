local Event = require("api.Event")

local function init_save()
   local s = save.autodig
   s.enabled = false
end

Event.register("base.on_init_save", "Init save (autodig)", init_save)
