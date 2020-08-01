local Event = require("api.Event")


-- TODO
-- local function archetype_on_spawn_monster(map)
-- end

local function archetype_on_map_renew_minor(map)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_renew_minor) then
      return
   end

   archetype.on_map_renew_minor(map)
end

Event.register("base.on_map_renew_minor", "Archetype callback (on_map_renew_minor)", archetype_on_map_renew_minor)

local function archetype_on_map_renew_major(map)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_renew_major) then
      return
   end

   archetype.on_map_renew_major(map)
end

Event.register("base.on_map_renew_major", "Archetype callback (on_map_renew_major)", archetype_on_map_renew_major)

local function archetype_on_map_renew_geometry(map)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_renew_geometry) then
      return
   end

   archetype.on_map_renew_geometry(map)
end

Event.register("base.on_map_renew_geometry", "Archetype callback (on_map_renew_geometry)", archetype_on_map_renew_geometry)

local function archetype_on_map_minor_events(map)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_minor_events) then
      return
   end

   archetype.on_map_minor_events(map)
end

Event.register("base.on_map_minor_events", "Archetype callback (on_map_minor_events)", archetype_on_map_minor_events)

local function archetype_on_map_major_events(map)
   local archetype = map:archetype()
   if not (archetype and archetype.on_map_major_events) then
      return
   end

   archetype.on_map_major_events(map)
end

Event.register("base.on_map_major_events", "Archetype callback (on_map_major_events)", archetype_on_map_major_events)
