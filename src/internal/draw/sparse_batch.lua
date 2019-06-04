local IBatch = require("internal.draw.IBatch")
local sparse_batch = class("sparse_batch", IBatch)

function sparse_batch:init(width, height, atlas)
   self.width = width
   self.height = height
   self.atlas = atlas

   self.tiles = {}
   self.xcoords = {}
   self.ycoords = {}
   self.xoffs = {}
   self.yoffs = {}
   self.colors = {}

   self.free_indices = {}

   self.batch = love.graphics.newSpriteBatch(atlas.image)
   self.updated = true
   self.tile_width = self.atlas.tile_width
   self.tile_height = self.atlas.tile_height
end

function sparse_batch:find_bounds(x, y)
   local draw_width = love.graphics.getWidth()
   local draw_height = love.graphics.getHeight()
   local tx = math.floor(x / self.tile_width) - 1
   local ty = math.floor(y / self.tile_height) - 1
   local tdx = math.min(math.ceil((x + draw_width) / self.tile_width), self.width)
   local tdy = math.min(math.ceil((y + draw_height) / self.tile_height), self.height)
   return tx, ty, tdx, tdy
end

function sparse_batch:find_tile_at(x, y)
   local ind
   local xc = self.xcoords
   local yc = self.ycoords

   for i=1,#self.tiles do
      if xc[i] == x and yc[i] == y then
         ind = i
         break
      end
   end

   return ind
end

function sparse_batch:add_tile(params)
   -- TODO: needs z-ordering...
   local ind = table.pop(self.free_indices) or #self.tiles + 1
   self.tiles[ind] = params.tile or 0
   self.xcoords[ind] = params.x or 0
   self.ycoords[ind] = params.y or 0
   self.xoffs[ind] = params.x_offset or 0
   self.yoffs[ind] = params.y_offset or 0
   self.updated = true
   return ind
end

function sparse_batch:remove_tile(ind)
   self.tiles[ind] = 0
   -- TODO: keep this array sorted from smallest to largest.
   table.push(self.free_indices, ind)
   self.updated = true
end

function sparse_batch:set_tiles(tiles)
   self.tiles = tiles
   self.updated = true
end

function sparse_batch:draw(x, y)
   -- slight speedup
   local batch = self.batch
   local tw = self.tile_width
   local th = self.tile_height

   local ox = tw - (x % tw)
   local oy = th - (y % th)

   if self.updated then
      local tx, ty, tdx, tdy = self:find_bounds(x, y)

      local tiles = self.atlas.tiles
      local self_tiles = self.tiles
      local xc = self.xcoords
      local yc = self.ycoords
      local xo = self.xoffs
      local yo = self.yoffs

      batch:clear()

      for ind, tile in ipairs(self_tiles) do
         if tile ~= 0 then
            local cx = xc[ind]
            local cy = yc[ind]
            if cx >= tx - 1 and cx < tdx and cy >= ty - 1 and cy < tdy then
               local x = (cx - tx - 1) * tw + xo[ind]
               local y = (cy - ty - 1) * th + yo[ind]
               -- if color then
               -- batch.setColor(self.colors[ind])
               -- color_set = true
               -- elseif not color_set then
               -- batch.setColor(1, 1, 1)
               -- color_set = false
               -- end
               batch:add(tiles[tile], x, y)
            end
         end
      end

      batch:flush()

      self.updated = false
   end

   love.graphics.draw(batch, ox - tw, oy - th)
end

return sparse_batch
