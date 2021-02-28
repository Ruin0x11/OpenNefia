local ICoords = require("internal.draw.coords.ICoords")
local iso_coords = class.class("iso_coords", ICoords)

function iso_coords:get_size()
   return 64, 64
end

function iso_coords:get_tiled_width(w)
   return math.floor(w / 64)
end

function iso_coords:get_tiled_height(h)
   return math.floor(h / 64)
end

function iso_coords:tile_to_screen(tx, ty)
   local iso_x = ((tx - ty) * ((64/2))-1) + (64/4)
   local iso_y = ((tx + ty) * ((64/4))-1)
   return iso_x, iso_y
end

function iso_coords:screen_to_tile(sx, sy)
   local tile_x = (sx / (64/2) + sy / (64/2)) /2;
   local tile_y = (sy / (64/2) -(sx / (64/2))) /2;
   return tile_x, tile_y
end

function iso_coords:find_bounds(x, y, width, height)
   local tile_width = 64
   local tile_height = 64
   local draw_width = love.graphics.getWidth()*2
   local draw_height = love.graphics.getHeight()*2
   local tx = math.floor(x / tile_width) - 1 - math.floor(draw_width / tile_width / 2)
   local ty = math.floor(y / tile_height) - 1 - math.floor(draw_height / tile_height)
   local tdx = math.min(math.ceil((x + draw_width) / tile_width) * 4, width*2)
   local tdy = math.min(math.ceil((y + draw_height) / tile_height) * 4, height*2)
   return tx, ty, tdx, tdy
end

function iso_coords:get_start_offset(x, y, width, height)
   return love.graphics.getWidth()/2, -love.graphics.getHeight()/2, 64*2, 64
end

function iso_coords:get_draw_pos(tx, ty, mw, mh, width, height)
   local tile_size = 64
   local x = tx * tile_size
   local y = ty * tile_size
   return x, y
end

return iso_coords
