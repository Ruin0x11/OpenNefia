local Resolver = require("api.Resolver")
local data = require("internal.data")

local map_template = {}

local function bind_events(template)
   local events = table.deepcopy(template.events or {})

   if template.on_generate then
      events[#events+1] = {
         id = "base.on_map_generated",
         name = "map_template: on_generate",
         callback = template.on_generate,
         priority = 50000
      }
   end

   if template.on_load then
      events[#events+1] = {
         id = "base.on_map_loaded",
         name = "map_template: on_load",
         callback = template.on_load,
         priority = 50000
      }
   end

   if template.on_regenerate then
      events[#events+1] = {
         id = "base.on_map_regenerated",
         name = "map_template: on_regenerate",
         callback = template.on_regenerate,
         priority = 70000
      }
   end

   events[#events+1] = {
      id = "base.on_map_rebuilt",
      name = "map_template: on_rebuild",
      callback = function(map, params)
         local new_map = params.new_map

         if template.on_rebuild then
            template.on_rebuild(map, map.generated_with.params, new_map)
         end
      end,
      priority = 50000
   }

   return events
end

function map_template.generate(id, opts)
   local template = data["base.map_template"]:ensure(id)
   if template.map == nil then
      error(("Map template %s does not contain a `map` function."):format(id))
   end

   local copy = {}
   if template.copy then
      copy = Resolver.resolve(template.copy)
   end

   local map = template.map(opts)

   table.merge(map, copy)

   if template.unique then
      map.id = id
   end

   return map
end

function map_template.load(map)
   local template = data["base.map_template"]:ensure(map.id)

   -- Copy functions in the "copy" subtable back to the map, since
   -- they will not be serialized (they become nil).
   --
   -- NOTE: but this ignores the fact that maps can be generated in
   -- many ways that may not have a "copy" table available. In that
   -- case a data type for map entrances would have to be created.
   if template.copy then
      local copy = Resolver.resolve(template.copy)

      for k, v in pairs(copy) do
         if type(k) == "string" and k:sub(1, 1) ~= "_" then
            if type(v) == "function" and map[k] == nil then
               map[k] = v
            end
         end
      end
   end

   local events = bind_events(template)
   map:connect_self_multiple(events)
end

return map_template
