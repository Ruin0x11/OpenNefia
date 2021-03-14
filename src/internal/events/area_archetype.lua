local Event = require("api.Event")
local MapArchetype = require("api.MapArchetype")

local function generate_entrances_of_area_children(parent_map, params)
   MapArchetype.generate_area_archetype_entrances(parent_map)
end

Event.register("base.on_generate_area_floor", "Generate entrances for the areas contained in the area", generate_entrances_of_area_children)
