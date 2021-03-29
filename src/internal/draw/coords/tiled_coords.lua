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
   local tdx = tx + math.ceil((draw_width) / tile_width) + 2
   local tdy = ty + math.ceil((draw_height) / tile_height) + 2
   return tx, ty, tdx, tdy
end

function tiled_coords:get_draw_pos(sx, sy, mw, mh, width, height)
   local tile_size = 48

   local msw = mw * tile_size
   local msh = mh * tile_size

   local max_x = (msw - width)
   local max_y = (msh - height)

   local offset_x = math.max((width - msw) / 2, 0)
   local offset_y = math.max((height - msh) / 2, 0)

   local x = math.clamp(-sx + width/2, -max_x, 0)
   local y = math.clamp(-sy + height/2, -max_y, 0)
   return math.floor(x + offset_x), math.floor(y + offset_y)
end

return tiled_coords
