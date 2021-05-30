local InstancedMap = require("api.InstancedMap")

local MapSerial = {}

local function build_geometry(onmap)
   local map = InstancedMap:new(onmap.width, onmap.height)

   for i, index in ipairs(onmap.tiles) do
      local x = (i - 1) % map:width()
      local y = math.floor((i - 1) / map:width())
      local tile_id = assert(onmap.tileset[index])
      map:set_tile(x, y, tile_id)
   end

   return map
end

function MapSerial.serial_to_editor(onmap)
   local map = build_geometry(onmap)

   return {
      map = map,
      modified = false,
      offset_x = 0,
      offset_y = 0
   }
end

function MapSerial.editor_to_serial(opened_map)
   local width = opened_map.map:width()
   local height = opened_map.map:height()

   local tiles = {}
   local tileset = {}
   local tile_index = 0
   local seen = table.set {}

   for _, x, y, tile in opened_map.map:iter_tiles() do
      local index = seen[tile._id]
      if index == nil then
         tile_index = tile_index + 1
         seen[tile._id] = tile_index
         tileset[tile_index] = tile._id
         index = tile_index
      end
      tiles[#tiles+1] = index
   end

   return {
      width = width,
      height = height,
      tiles = tiles,
      tileset = tileset
   }
end

function MapSerial.serial_to_map(onmap)
   local map = build_geometry(onmap)

   return map
end

return MapSerial
