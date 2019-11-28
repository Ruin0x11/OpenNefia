local Log = require("api.Log")
local Resolver = require("api.Resolver")
local Map = require("api.Map")
local MapArea = require("api.MapArea")

--- An Elona 1.22-style map template which uses a static map file.
data:add_type {
   name = "map_template",
   schema = schema.Record {
      map = schema.String,
      elona_id = schema.Optional(schema.Number),
      copy = schema.Optional(schema.Table),
      areas = schema.Optional(schema.Table),
      objects = schema.Optional(schema.Table),
      on_generate = schema.Optional(schema.Function),
   }
}
data:add_index("elona_sys.map_template", "elona_id")

--- Obtains the map generation parameters for an entry in the "areas"
--- field of a map_template.
local function generator_for_area(area_entry)
   local generator = area_entry.map
   if type(generator) == "string" then
      generator = { generator = "elona_sys.map_template", params = { id = generator } }
   end

   assert(generator.generator and generator.params, "Map must be either a map_template ID or generator params like { generator = \"elona_sys.map_template\", params = { id = \"base.vernis\" } }")

   return generator
end

local function generator_for_template(template)
   local map = template.map

   if type(map) == "string" then
      -- Assume it is the name of an Elona 1.22 .map file.
      return { generator = "elona_sys.elona122", params = { name = template.map } }
   end

   assert(type(map) == "table")
   assert(type(map.generator) == "string")

   return map
end

local function generate_from_map_template(self, params, opts)
   if not params.id then
      error("Map template ID must be provided")
   end

   local template = data["elona_sys.map_template"]:ensure(params.id)

   local generator = generator_for_template(template)

   local success, map = Map.generate(generator.generator, generator.params, opts)
   if not success then
      error("Could not generate map: " .. map)
   end

   if template.copy then
      local copy = Resolver.resolve(template.copy)
      table.merge(map, copy)
   end

   if template.areas then
      for _, area in ipairs(template.areas) do
         local area_generator_params = generator_for_area(area)
         local area_params = {}

         if params.area_uid then
            -- reuse existing area
            area_params = params.area_uid
         else
            -- generate new area
            area_params = { outer_map_id = params.id }
         end
         MapArea.create_entrance(area_generator_params, area_params, area.x, area.y, map)
      end
   end

   if template.copy then
      for k, v in pairs(template.copy) do
         if type(k) == "string" and k:sub(1, 1) ~= "_" then
            map[k] = v
         end
      end
   end

   map.events = template.events or {}

   if template.on_generate then
      template.on_generate(map)
   end

   return map, params.id
end

local function load_map_template(map, params, opts)
   local template = data["elona_sys.map_template"]:ensure(params.id)

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

   map.events = template.events or {}

   if template.on_load then
      template.on_load(map)
   end
end

local function on_enter(map, params, previous_map)
   local template = data["elona_sys.map_template"]:ensure(params.id)

   if template.on_enter then
      template.on_enter(map, previous_map)
   end
end

local function on_regenerate(map, params)
   local template = data["elona_sys.map_template"]:ensure(params.id)

   if template.on_regenerate then
      template.on_regenerate(map)
   end
end

data:add {
   _type = "base.map_generator",
   _id = "map_template",

   params = { id = "string" },
   generate = generate_from_map_template,
   load = load_map_template,
   on_enter = on_enter,
   on_regenerate = on_regenerate,
   get_image = function(params)
      return data["elona_sys.map_template"]:ensure(params.id).image
   end,

   almost_equals = function(self, other)
      return self.id == other.id
   end
}
