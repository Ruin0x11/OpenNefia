local IBatch = require("internal.draw.IBatch")
local draw = require("internal.draw")
local tile_batch = class("tile_batch", IBatch)

function tile_batch:init(width, height, atlas, coords)
   self.width = width
   self.height = height
   self.atlas = atlas
   self.coords = coords

   self.tiles = table.of(0, width * height)
   self.batch = love.graphics.newSpriteBatch(atlas.image)
   self.updated = true
   self.tile_width = self.atlas.tile_width
   self.tile_height = self.atlas.tile_height
end

function tile_batch:find_bounds(x, y)
   local draw_width = love.graphics.getWidth()
   local draw_height = love.graphics.getHeight()
   local tx = math.floor(x / self.tile_width) - 1
   local ty = math.floor(y / self.tile_height) - 1
   local tdx = math.min(math.ceil((x + draw_width) / self.tile_width), self.width)
   local tdy = math.min(math.ceil((y + draw_height) / self.tile_height), self.height)
   return tx, ty, tdx, tdy
end

function tile_batch:set_tiles(tiles)
   self.tiles = tiles
   self.updated = true
end

function tile_batch:update_tile(x, y, tile)
   if x >= 0 and y >= 0 and x < self.width and y < self.height then
      if self.atlas.tiles[tile] ~= nil then
         self.tiles[y*self.width+x+1] = tile
         self.updated = true
      end
   end
end

function tile_batch:draw(x, y)
   -- slight speedup
   local batch = self.batch
   local tw = self.tile_width
   local th = self.tile_height

   local sx, sy, ox, oy = self.coords:get_start_offset(x, y, draw.get_width(), draw.get_height())

   if self.updated then
      local tx, ty, tdx, tdy = self.coords:find_bounds(x, y, self.width, self.height)
      local tiles = self.atlas.tiles
      local self_tiles = self.tiles

      batch:clear()

      for y=ty,tdy do
         if y >= 0 and y < self.height then
            for x=tx,tdx do
               if x >= 0 and x < self.width then
                  local tile = self_tiles[y*self.width+x+1]
                  if tile ~= 0 then
                     local i, j = self.coords:tile_to_screen(x - tx, y - ty)
                     batch:add(tiles[tile], i, j)
                  end
               end
            end
         end
      end

      batch:flush()

      self.updated = false
   end

   love.graphics.draw(batch, sx + ox - tw, sy + oy - th)
end

return tile_batch
