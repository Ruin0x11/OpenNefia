local tiled_coords = class.class("tiled_coords")

function tiled_coords:load_tile(tile, x, y)
   love.graphics.draw(tile, x, y)
end

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

function tiled_coords:get_start_offset(x, y, width, height)
   local sx = 0
   local sy = 0
   if x < 0 then
      sx = math.floor(x / 2)
   end
   if y < 0 then
      sy = math.floor(y / 2)
   end
   return sx, sy, 48 - (x % 48), 48 - (y % 48)
end

function tiled_coords:get_draw_pos(tx, ty, mw, mh, width, height)
   local tile_size = 48
   local x = math.clamp(tx * tile_size - math.floor(width / 2) + math.floor(tile_size / 2), 0, mw * tile_size - width)
   local y = math.clamp(ty * tile_size - math.floor(height / 2) + math.floor(tile_size / 2), 0, mh * tile_size - height + (72 + 16))
   return x, y
end

return tiled_coords
