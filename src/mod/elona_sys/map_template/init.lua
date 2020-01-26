local I18N = require("api.I18N")
local Log = require("api.Log")
local Map = require("api.Map")
local MapArea = require("api.MapArea")
local Resolver = require("api.Resolver")

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

-- looks for stairs with the tags "stairs_up" and "stairs_down" and
-- connects them to the map.
local function connect_stairs(map, outer_map, generator)
   local dungeon_level = map.dungeon_level
   local stairs_up = map:iter_feats():filter(function(f) return f.label == "stairs_up" end):nth(1)
   local stairs_down = map:iter_feats():filter(function(f) return f.label == "stairs_down" end):nth(1)

   assert(stairs_up, "Map is missing feat with 'stairs_up' tag")
   -- stairs_down may be missing if the map is the bottommost floor of
   -- the dungeon

   -- connect the stairs up to the outer map
   stairs_up.map_uid = outer_map.uid
   assert(stairs_up.map_uid)
   print("stairsup", stairs_up.uid, stairs_up.map_uid)

   if stairs_down then
      generator.params.dungeon_level = dungeon_level + 1
      stairs_down.generator_params = generator
      Log.warn("Generator down: %s", inspect(generator))
   end
end

local function generate_from_map_template(self, params, opts)
   if not params.id then
      error("Map template ID must be provided")
   end

   local template = data["elona_sys.map_template"]:ensure(params.id)

   local generator = generator_for_template(template)

   local new_params = table.shallow_copy(generator.params)
   if params.dungeon_level then
      new_params.dungeon_level = params.dungeon_level
   end

   local success, map = Map.generate(generator.generator, new_params, opts)
   if not success then
      error(map, 0)
   end

   local generator_data = data["base.map_generator"]:ensure(generator.generator)
   if generator_data.connect_stairs then
      local next_generator = {
         generator = self._id,
         params = params
      }
      if generator.params.dungeon_level then
         next_generator.params.dungeon_level = generator.params.dungeon_level or next_generator.params.dungeon_level
         next_generator.params.deepest_dungeon_level = generator.params.deepest_dungeon_level
      end
      connect_stairs(map, opts.outer_map, next_generator)
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

   map.name = I18N.get("map.unique." .. params.id .. ".name")

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
      template.on_regenerate(map, params)
   end
end

local function transfer_stairs(old_map, new_map, params)
   local assoc = function(f) return f.label or false, f end
   local old_stairs = old_map:iter_feats():map(assoc):to_map()
   local new_stairs = new_map:iter_feats():map(assoc):to_map()

   for label, old_stair in pairs(old_stairs) do
      if type(label) == "string" then
         local new_stair = new_stairs[label]
         if new_stair and old_stair._id == new_stair._id then
            if old_stair.map_uid == nil then
               Log.warn("Transfering generated stair %d -> %d", old_stair.uid, new_stair.uid)
               assert(old_stair.generator_params)
               new_stair.map_uid = nil
               new_stair.generator_params = old_stair.generator_params
            else
               Log.warn("Transfering ungenerated stair %d -> %d", old_stair.uid, new_stair.uid)
               new_stair.map_uid = old_stair.map_uid
               new_stair.generator_params = old_stair.generator_params
            end
         else
            Log.error("Missing stairs in rebuilt dungeon with label %s", label)
         end
      end
   end

   new_map.dungeon_level = old_map.dungeon_level
end

local function on_rebuild(map, params, new_map, travel_to_params)
   local template = data["elona_sys.map_template"]:ensure(params.id)

   transfer_stairs(map, new_map, travel_to_params)

   if template.on_rebuild then
      template.on_rebuild(map, params, new_map)
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
   on_rebuild = on_rebuild,
   get_image = function(params)
      return data["elona_sys.map_template"]:ensure(params.id).image
   end,

   almost_equals = function(self, other)
      return self.id == other.id
   end
}
