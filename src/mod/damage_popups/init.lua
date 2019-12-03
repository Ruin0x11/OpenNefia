local Event = require("api.Event")
local DamagePopup = require("mod.damage_popups.api.DamagePopup")

Event.register("base.on_init_save", "Init save (damage popups)", function()
                  save.damage_popups.popups = { count = 0 }
end)

Event.register("base.on_map_enter", "Clear damage popups", DamagePopup.clear)
