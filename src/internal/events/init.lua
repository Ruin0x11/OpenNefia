local events = {}

function events.require_all()
   require("internal.events.init_save")
   require("internal.events.on_hotload")
   require("internal.events.damage_hp")
   require("internal.events.map_init")
   require("internal.events.map_exit")
   require("internal.events.map_archetype")
   require("internal.events.area_archetype")
end

return events
