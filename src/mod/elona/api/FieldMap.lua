local InstancedMap = require("api.InstancedMap")
local MapgenUtils = require("mod.elona.api.MapgenUtils")

local FieldMap = {}

local default_field_type = "elona.plains"

function FieldMap.generate(stood_tile, width, height, outer_map)
   -- >>>>>>>> shade2/map.hsp:1504 		mModerateCrowd =4 ...
   local tile = data["base.map_tile"]:ensure(stood_tile)

   local field_type = tile.field_type or default_field_type

   local field = data["elona.field_type"][field_type]
   if not field then
      field_type = default_field_type
      field = data["elona.field_type"]:ensure(field_type)
   end

   local map = InstancedMap:new(width, height)
   map:clear(field.default_tile)

   if field.tiles then
      for _, v in ipairs(field.tiles) do
         MapgenUtils.spray_tile(map, v.id, v.density)
      end
   end

   field:generate(map)

   local x = math.floor(map:width() / 2)
   local y = math.floor(map:height() / 2)
   map.player_start_pos = { x = x, y = y }
   map.is_temporary = true

   map.types = { "field" }
   map.tile_type = 4
   map.max_crowd_density = 4
   map.turn_cost = 10000
   map.level = 1
   map.is_indoor = false
   map.has_anchored_npcs = false
   map.default_ai_calm = 0
   map.default_tile = field.fog

   return map
   -- <<<<<<<< shade2/map.hsp:1576 		map_placePlayer	 ..
end

function FieldMap.generate_default(stood_tile, prev_map)
   local map = FieldMap.generate(stood_tile, 34, 22, prev_map)

   -- >>>>>>>> shade2/map.hsp:1586 		if encounter=0{ ...
   for _ = 1, map:calc("max_crowd_density") do
      MapgenUtils.generate_chara(map)
   end
   -- <<<<<<<< shade2/map.hsp:1591 			} ..

   return map
end

return FieldMap
