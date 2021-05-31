local InstancedMap = require("api.InstancedMap")

local MapSerial = {}

function MapSerial.build_geometry(onmap)
   local map = InstancedMap:new(onmap.width, onmap.height)

   for i, index in ipairs(onmap.tiles) do
      local x = (i - 1) % map:width()
      local y = math.floor((i - 1) / map:width())
      local tile_id = assert(onmap.tileset[index])
      map:set_tile(x, y, tile_id)
   end

   return map
end

function MapSerial.serial_to_map(onmap)
   local map = MapSerial.build_geometry(onmap)

   return map
end

return MapSerial
