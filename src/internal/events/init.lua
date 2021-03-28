local events = {}

function events.require_all()
   require("internal.events.init_save")
   require("internal.events.on_hotload")
   require("internal.events.damage_hp")
   require("internal.events.map_init")
   require("internal.events.map_exit")
   require("internal.events.map_archetype")
   require("internal.events.area_archetype")
   require("internal.events.chara_refresh")
   require("internal.events.item_description")
   require("internal.events.item_refresh")
   require("internal.events.chara_activity")
   require("internal.events.debug")
   require("internal.events.map_delete")
   require("internal.events.item")
   require("internal.events.widget")
end

return events
