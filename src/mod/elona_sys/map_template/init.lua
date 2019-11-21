local Log = require("api.Log")
local Resolver = require("api.Resolver")
local Map = require("api.Map")
local MapArea = require("api.MapArea")

--- An Elona 1.22-style map template which uses a static map file.
data:add_type {
   name = "map_template",
   schema = schema.Record {
      map = schema.String,
      copy_to_map = schema.Optional(schema.Table),
      areas = schema.Optional(schema.Table),
      objects = schema.Optional(schema.Table),
      on_generate = schema.Optional(schema.Function),
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

   -- determines if two entrances are equivalent and should be
   -- considered a valid target for entrance relinking.
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
         -- The new map's entrance layout differs from the old map -
         -- it isn't deterministically generated or a breaking change
         -- was made. There was a map entrance on the old map leading
         -- somewhere that has been generated, but the entrance for
         -- that map is missing in the new map, so the subarea will
         -- become inaccessible.
         --
         -- TODO: it should be possible specify the entrances so they
         -- can be linked without using partial equivalence, perhaps
         -- by adding a unique ID on the entrance.
         Log.warn("Generated map is missing entrance for map %d", uid)
      end
   end

   for index, found_map in ipairs(area_index_to_found_map) do
      local area = template.areas[index]
      MapArea.set_entrance(found_map, outer_map, area.x, area.y)
   end
end

local function generate_from_map_template(self, params, opts)
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
         -- The map is being refreshed, so any entrances leading to
         -- other maps on the old map should be linked to the new map.
         -- For example, if Vernis is being generated and the Rogue's
         -- Den entrance was previously visited on the old copy of
         -- Vernis, then the entrance to Rogue's Den should be linked
         -- to the new copy of Vernis. If this isn't done then then
         -- that copy of the Rogue's Den will become inaccessible.
         migrate_map_entrances(template, map, opts.existing)
      else
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
   end

   if template.copy then
      for k, v in pairs(template.copy) do
         if type(k) == "string" and k:sub(1, 1) ~= "_" then
            map[k] = v
         end
      end
   end

   if template.on_generate then
      template.on_generate(map)
   end

   return map, params.id
end

local function load_map_template(map, params, opts)
   local template = data["elona_sys.map_template"]:ensure(params.id)

   -- Copy functions in the "copy" subtable back to the map, since
   -- they will not be serialized (they become nil).
   if template.copy then
      for k, v in pairs(template.copy) do
         if type(k) == "string" and k:sub(1, 1) ~= "_" then
            if type(v) == "function" and map[k] == nil then
               map[k] = v
            end
         end
      end
   end

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
