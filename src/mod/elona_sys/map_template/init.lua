local Log = require("api.Log")
local Resolver = require("api.Resolver")
local Map = require("api.Map")
local MapArea = require("api.MapArea")

data:add_type {
   name = "map_template",
   schema = schema.Record {
      map = schema.String,
      copy_to_map = schema.Optional(schema.Table),
      areas = schema.Optional(schema.Table),
      objects = schema.Optional(schema.Table),
   }
}

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
   return { generator = "elona_sys.elona122", params = { name = template.map } }
end

-- Moves the entrances from an existing map to a new map by
-- correlating the maps on disk to the generators in the "areas" field
-- on a map template. To check if two maps are the same, the
-- parameters used to generate each one are compared.
local function migrate_map_entrances(template, outer_map, existing)
   local entrances = MapArea.iter_map_entrances("generated", existing)
      :map(function(e)
            local s, m = Map.load(e.map_uid)
            assert(s)

            return { entrance = e, map = m }
          end)
      :to_list()

   local area_index_to_found_map = {}

   local function almost_equals(a, b)
      if a.generator ~= b.generator then
         return false
      end

      local g = data["base.map_generator"]:ensure(a.generated_with.id)
      return g.almost_equals(a.generated_with.params,
                             b.generated_with.params)
   end

   for i, area in ipairs(template.areas) do
      for _, entrance in pairs(entrances) do
         if not entrance.found then
            local generator = generator_for_area(area)

            if almost_equals(generator, entrance.map.generated_with) then
               area_index_to_found_map[i] = entrance.map
               entrance.found = true
            end
         end
      end
   end

   for uid, entrance in pairs(entrances) do
      if not entrance.found then
         Log.warn("Generated map is missing entrance for map %d", uid)
      end
   end

   for index, found_map in ipairs(area_index_to_found_map) do
      local area = template.areas[index]
      MapArea.set_entrance(found_map, outer_map, area.x, area.y)
   end
end

local function load_map_template(self, params, opts)
   if not params.id then
      error("Map template ID must be provided")
   end

   local template = data["elona_sys.map_template"]:ensure(params.id)

   local generator = generator_for_template(template)

   local success, map = Map.generate(generator.generator, generator.params)
   if not success then
      error("Could not generate map: " .. map)
   end

   if template.copy_to_map then
      local copy = Resolver.resolve(template.copy_to_map)

      for k, v in pairs(copy) do
         map[k] = v
      end
   end

   if template.areas then
      if opts.existing then
         migrate_map_entrances(template, map, opts.existing)
      else
         for _, area in ipairs(template.areas) do
            local area_generator_params = generator_for_area(area)
            MapArea.create_entrance(area_generator_params, area.x, area.y, map)
         end
      end
   end

   if template.on_generate then
      template.on_generate(map)
   end

   return map
end

data:add {
   _type = "base.map_generator",
   _id = "map_template",

   params = { id = "string" },
   generate = load_map_template,

   almost_equals = function(self, other)
      return self.id == other.id
   end
}
