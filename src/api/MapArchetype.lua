local data = require("internal.data")
local Log = require("api.Log")

local MapArchetype = {}

function MapArchetype.generate_map(map_archetype_id, area, floor, params)
   local map_archetype = data["base.map_archetype"]:ensure(map_archetype_id)
   assert(type(map_archetype.on_generate_map) == "function", ("Map archetype '%s' was associated with floor '%d' of area archetype '%s', but it doesn't have an `on_generate_floor` callback.")
             :format(map_archetype_id, floor, area._archetype))
   assert(type(area) == "table", "No area provided")
   floor = floor or 1
   params = params or {}

   params.is_first_generation = true

   local map = map_archetype.on_generate_map(area, floor, params)
   if map._archetype == nil then
      Log.debug("Map archetype unset on new floor, setting to %s", map_archetype_id)
      map:set_archetype(map_archetype_id, { set_properties = true })
   else
      Log.debug("Map archetype was already set to %s on generation", map._archetype)
   end

   return map
end

function MapArchetype.generate_map_and_area(map_archetype_id, floor, params, parent_area)
   local InstancedArea = require("api.InstancedArea")
   local Area = require("api.Area")
   local Map = require("api.Map")

   local area = InstancedArea:new()
   local floor = floor or 1
   local map = MapArchetype.generate_map(map_archetype_id, area, floor, params)
   area:add_floor(map)
   Area.register(area, { parent = parent_area or Area.for_map(Map.current()) })

   return map
end

return MapArchetype
