local Draw = require("api.Draw")
local InstancedMap = require("api.InstancedMap")
local Color = require("mod.extlibs.api.Color")
local Map = require("api.Map")

-- A simple module for extracting a map's tiles into a serialized format, and
-- converting the resulting tile layout into images or new maps.
local Layout = {}

function Layout.extract_params(layout)
   local split = string.split(layout.tiles)
   local width = split[1]:len()
   local height = #split
   local tiles = {}

   for i, s in ipairs(split) do
      if s:len() ~= width then
         if i == #split then
            height = height - 1
            break
         end
         error(("invalid row of width '%d' passed (expected '%d')"):format(s:len(), width))
      end
      for c in string.chars(s) do
         tiles[#tiles+1] = c
      end
   end

   return width, height, tiles
end

function Layout.to_image_data(layout)
   local color_to_tile = {
      tiles = {},
      callbacks = {}
   }

   local width, height, tiles = Layout.extract_params(layout)

   local tile_to_pixel = table.shallow_copy(layout.tileset)
   local color_count = table.count(tile_to_pixel) - 1
   for cnt, k in ipairs(table.keys(tile_to_pixel)) do
      local i = 1.0 * ((cnt-1) / color_count)
      local r = i
      local g = i
      local b = i
      tile_to_pixel[k] = { r, g, b }

      local number = Color.to_number(Draw.color_to_bytes(r, g, b, 1))
      color_to_tile.tiles[number] = layout.tileset[k]
      if layout.callbacks then
         color_to_tile.callbacks[number] = layout.callbacks[k]
      end
   end

   local image_data = Draw.new_image_data(width, height)

   local function map(x, y)
      local tile = tiles[(y * width) + x + 1]
      local pixel = tile_to_pixel[tile]
      if not pixel then
         error(("unknown tile %s"):format(tile))
      end
      return pixel[1], pixel[2], pixel[3], 255
   end

   image_data:mapPixel(map)

   return image_data, color_to_tile
end

local TILES = {
   "elona.cobble",
   "elona.wall_brick_top",
   "elona.grass",
   "elona.wood_floor_4",
   "elona.wall_decor_top",
}

function Layout.from_image_data(image_data, color_to_tile)
   local byte = string.byte(".")
   local tileset = {}
   local callbacks = {}
   local seen = {}
   local tiles = ""
   local last_y = 0
   local idx = 0

   local function map(x, y, r, g, b, a)
      local number = Color.to_number(Draw.color_to_bytes(r, g, b, a))
      if not seen[number] then
         local c = string.char(byte)
         local tile = TILES[((idx)%#TILES)+1]
         idx = idx + 1
         if color_to_tile then
            tile = color_to_tile.tiles[number]
            if tile == nil then
               error(("Missing tile for color '%d'"):format(number))
            end
         end
         tileset[c] = tile
         callbacks[c] = color_to_tile.callbacks[number] or nil
         seen[number] = c
         byte = byte + 1
      end
      if last_y < y then
         tiles = tiles .. "\n"
         last_y = y
      end
      local c = seen[number]
      tiles = tiles .. c

      return r, g, b, a
   end

   image_data:mapPixel(map)

   return { tiles = tiles, tileset = tileset, callbacks = callbacks }
end

function Layout.to_map(layout)
   local width, height, tiles = Layout.extract_params(layout)
   local default = layout.tileset.default or nil

   local map = InstancedMap:new(width, height)

   local i = 1
   for y = 0, height - 1 do
      for x = 0, width - 1 do
         local tile_id = layout.tileset[tiles[i]] or default
         assert(tile_id, "No map tile for symbol " .. tostring(tiles[i]))
         map:set_tile(x, y, tile_id)
         if layout.callbacks and layout.callbacks[tiles[i]] then
            layout.callbacks[tiles[i]](map, x, y)
         end
         i = i + 1
      end
   end

   if map.player_start_pos == nil then
      local start_x, start_y = Map.find_free_position(math.floor(width/2), math.floor(height/2), {}, map)
      map.player_start_pos = { x = start_x, y = start_y }
   end

   return map
end

function Layout.from_map(map)
   assert(class.is_an(InstancedMap, map))

   local byte = string.byte(".")
   local tileset = {}
   local seen = {}
   local tiles = ""
   local last_y = 0

   for _, x, y, tile in map:iter_tiles() do
      local tile_id = tile._id
      if not seen[tile_id] then
         local c = string.char(byte)
         tileset[c] = tile_id
         seen[tile_id] = c
         byte = byte + 1
      end

      if last_y < y then
         tiles = tiles .. "\n"
         last_y = y
      end
      local c = seen[tile_id]
      tiles = tiles .. c
   end

   return { tiles = tiles, tileset = tileset }
end

return Layout
