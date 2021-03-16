local ICoords = require("internal.draw.coords.ICoords")
local tiled_coords = class.class("tiled_coords", ICoords)

function tiled_coords:get_size()
   return 48, 48
end

function tiled_coords:get_tiled_width(w)
   local add = 0
   if w % 48 ~= 0 then
      add = 1
   end
   return math.floor(w / 48) + 1
end

function tiled_coords:get_tiled_height(h)
   local add = 0
   if h % 48 ~= 0 then
      add = 1
   end
   return math.floor(h / 48) + 1
end

function tiled_coords:tile_to_screen(tx, ty)
   return tx * 48, ty * 48
end

function tiled_coords:screen_to_tile(sx, sy)
   return math.floor(sx / 48), math.floor(sy / 48)
end

function tiled_coords:find_bounds(x, y, draw_width, draw_height)
   local tile_width = 48
   local tile_height = 48
   local tx = math.max(0, math.floor(-x / tile_width)) - 1
   local ty = math.max(0, math.floor(-y / tile_height)) - 1
   local tdx = tx + math.ceil((draw_width) / tile_width) + 1
   local tdy = ty + math.ceil((draw_height) / tile_height) + 1
   return tx, ty, tdx, tdy
end

function tiled_coords:get_start_offset(x, y, width, height)
   local sx = 0
   local sy = 0
   if x < 0 then
      sx = math.floor(x / 2)
   end
   if y < 0 then
      sy = math.floor(y / 2)
   end
   return sx + math.floor(48 - (x % 48)), sy + math.floor(48 - (y % 48)), 0, 0
end

function tiled_coords:get_draw_pos(tx, ty, mw, mh, width, height)
   local tile_size = 48
   local x = math.clamp(tx * tile_size - math.floor(width / 2) + math.floor(tile_size / 2), 0, mw * tile_size - width)
   local y = math.clamp(ty * tile_size - math.floor(height / 2) + math.floor(tile_size / 2), 0, mh * tile_size - height + (72 + 16))
   return x, y
end

return tiled_coords
