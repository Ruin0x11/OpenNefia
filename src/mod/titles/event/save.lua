local Event = require("api.Event")

local function init_save()
   local s = save.titles
   s.title_states = {}
end

Event.register("base.on_init_save", "Init save (titles)", init_save)
