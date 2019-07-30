local Event = require("api.Event")

Event.register("base.on_init_save", "Init save (damage popups)", function() save.damage_popups.popups = { count = 0 } end)
