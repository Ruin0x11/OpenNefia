local Draw = require("api.Draw")

local tiled_coords = class("tiled_coords")

function tiled_coords:load_tile(tile, x, y)
   love.graphics.draw(tile, x, y)
end

function tiled_coords:get_size()
   return 48, 48
end

function tiled_coords:tile_to_screen(tx, ty)
   return (tx - 1) * 48, (ty - 1) * 48
end

function tiled_coords:find_bounds(x, y, width, height)
   local tile_width = 48
   local tile_height = 48
   local draw_width = love.graphics.getWidth()
   local draw_height = love.graphics.getHeight()
   local tx = math.floor(x / tile_width) - 1
   local ty = math.floor(y / tile_height) - 1
   local tdx = math.min(math.ceil((x + draw_width) / tile_width), width)
   local tdy = math.min(math.ceil((y + draw_height) / tile_height), height)
   return tx, ty, tdx, tdy
end

function tiled_coords:get_start_offset(x, y)
   return 0, 0, 48 - (x % 48), 48 - (y % 48)
end

function tiled_coords:get_draw_pos(tx, ty, mw, mh)
   local tile_size = 48
   local x = math.clamp(tx * tile_size - Draw.get_width() / 2 + (tile_size / 2), 0, mw * tile_size - Draw.get_width())
   local y = math.clamp(ty * tile_size - Draw.get_height() / 2 + (tile_size / 2), 0, mh * tile_size - Draw.get_height() + (72 + 16))
   return x, y
end

return tiled_coords
