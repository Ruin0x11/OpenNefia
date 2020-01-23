local IBatch = require("internal.draw.IBatch")
local Draw = require("api.Draw")
local sparse_batch = class.class("sparse_batch", IBatch)
local SkipList = require("api.SkipList")

function sparse_batch:init(width, height, atlas, coords, offset_x, offset_y)
   self.width = width
   self.height = height
   self.atlas = atlas
   self.coords = coords

   self.tiles = {}
   self.xcoords = {}
   self.ycoords = {}
   self.xoffs = {}
   self.yoffs = {}
   self.rotations = {}
   self.colors_r = {}
   self.colors_g = {}
   self.colors_b = {}
   self.z_orders = {}

   self.free_indices = {}

   self.batch = love.graphics.newSpriteBatch(atlas.image)
   self.updated = true
   self.tile_width = self.atlas.tile_width
   self.tile_height = self.atlas.tile_height
   self.offset_x = offset_x or 0
   self.offset_y = offset_y or 0
   self.ordering = SkipList:new()
end

function sparse_batch:get_tile(ind)
   return self.tiles[ind], self.xcoords[ind], self.ycoords[ind]
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
   local ind = table.remove(self.free_indices) or #self.tiles + 1

   local z_order = params.z_order or 0
   self.ordering:insert(z_order, ind)

   params.color = params.color or {}
   self.tiles[ind] = params.tile or ""
   self.xcoords[ind] = params.x or 0
   self.ycoords[ind] = params.y or 0
   self.xoffs[ind] = params.x_offset or 0
   self.yoffs[ind] = params.y_offset or 0
   self.rotations[ind] = params.rotation or 0
   self.colors_r[ind] = (params.color[1] or 255) / 255
   self.colors_g[ind] = (params.color[2] or 255) / 255
   self.colors_b[ind] = (params.color[3] or 255) / 255
   self.z_orders[ind] = z_order
   self.updated = true
   return ind
end

function sparse_batch:remove_tile(ind)
   self.tiles[ind] = 0
   table.insert(self.free_indices, ind)
   assert(self.ordering:delete(self.z_orders[ind], ind))
   self.updated = true
end

function sparse_batch:clear()
   self.tiles = {}
   self.xcoords = {}
   self.ycoords = {}
   self.xoffs = {}
   self.yoffs = {}
   self.rotations = {}
   self.colors_r = {}
   self.colors_g = {}
   self.colors_b = {}
   self.z_orders = {}
   self.ordering = SkipList:new()

   self.free_indices = {}

   self.updated = true
end

function sparse_batch:set_tiles(tiles)
   self.tiles = tiles
   self.updated = true
end

function sparse_batch:set_tile_offsets(ind, ox, oy)
   self.xoffs[ind] = ox
   self.yoffs[ind] = oy
   self.updated = true
end

function sparse_batch:draw(x, y, offset_x, offset_y)
   -- slight speedup
   local batch = self.batch
   local tw = self.tile_width
   local th = self.tile_height
   offset_x = offset_x or 0
   offset_y = offset_y or 0

   local sx, sy, ox, oy = self.coords:get_start_offset(x, y, Draw.get_width(), Draw.get_height())

   if self.updated then
      local tx, ty, tdx, tdy = self.coords:find_bounds(x, y, self.width, self.height)

      local self_tiles = self.tiles
      local tiles = self.atlas.tiles
      local xc = self.xcoords
      local yc = self.ycoords
      local xo = self.xoffs
      local yo = self.yoffs
      local rots = self.rotations
      local cr = self.colors_r
      local cg = self.colors_g
      local cb = self.colors_b

      batch:clear()

      for _, _, ind in self.ordering:iterate() do
         local tile = assert(self_tiles[ind])
         if tile ~= 0 then
            local cx = xc[ind]
            local cy = yc[ind]
            if cx >= tx - 1 and cx < tdx and cy >= ty - 1 and cy < tdy then
               local i, j = self.coords:tile_to_screen(cx - tx, cy - ty)
               local px = i + xo[ind]
               local py = j + yo[ind]
               if cr[ind] then
                  batch:setColor(cr[ind], cg[ind], cb[ind])
               else
                  batch:setColor(1, 1, 1)
               end
               local tile_tbl = tiles[tile]
               if tile_tbl ~= nil then
                  local _, _, ttw, tth = tile_tbl.quad:getViewport()
                  batch:add(tile_tbl.quad,
                            px + (ttw / 2),
                            py + tile_tbl.offset_y + (tth / 2),
                            rots[ind],
                            1,
                            1,
                            ttw / 2,
                            tth / 2)
               end
            end
         end
      end

      batch:setColor(1, 1, 1)
      batch:flush()

      self.updated = false
   end

   love.graphics.draw(batch, sx + ox - tw + offset_x, sy + oy - th + offset_y)
end

return sparse_batch
