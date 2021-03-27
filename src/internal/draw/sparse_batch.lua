local anim = require("internal.draw.anim")
local Draw = require("api.Draw")
local IBatch = require("internal.draw.IBatch")
local IChipRenderable = require("api.gui.IChipRenderable")
local SkipList = require("api.SkipList")
local sparse_batch = class.class("sparse_batch", IBatch)

function sparse_batch:init(width, height, offset_x, offset_y)
   self.width = width
   self.height = height
   self.atlas = nil
   self.coords = nil

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
   self.drawables = {}
   self.drawables_after = {}

   self.free_anims = {}

   self.batches = {}
   self.to_draw_inds = {}
   self.to_draw_drawables = {}
   self.updated = true
   self.tile_width = nil
   self.tile_height = nil
   self.offset_x = offset_x or 0
   self.offset_y = offset_y or 0
   self.ordering = SkipList:new()
end

function sparse_batch:on_theme_switched(atlas, coords)
   self.atlas = atlas
   self.coords = coords
   self.tile_width = self.atlas.tile_width
   self.tile_height = self.atlas.tile_height
   self:clear()
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

function sparse_batch:set_tile_image(ind, tile)
   if type(tile) == "string" then
      if self.tiles[ind] and self.tiles[ind].tile_id == tile then
         return
      end

      local the_anim = table.remove(self.free_anims)
      if the_anim == nil then
         the_anim = self.atlas:make_anim(tile)
      else
         self.atlas:update_anim(the_anim, tile)
      end
      tile = the_anim
   end

   self.tiles[ind] = tile
end

function sparse_batch:add_tile(ind, params)
   if params.tile == nil or params.tile == "" then
      return
   end

   local z_order = params.z_order or 0
   self.ordering:insert(z_order, ind)

   local tile = params.tile
   if type(params.tile) == "string" then
      local the_anim = table.remove(self.free_anims)
      if the_anim == nil then
         the_anim = self.atlas:make_anim(params.tile)
      else
         self.atlas:update_anim(the_anim, params.tile)
      end
      tile = the_anim
   end

   self.tiles[ind] = tile
   self.xcoords[ind] = params.x or 0
   self.ycoords[ind] = params.y or 0
   self.xoffs[ind] = params.x_offset or 0
   self.yoffs[ind] = params.y_offset or 0
   self.rotations[ind] = params.rotation or 0
   if params.color then
      self.colors_r[ind] = (params.color[1] or 255) / 255
      self.colors_g[ind] = (params.color[2] or 255) / 255
      self.colors_b[ind] = (params.color[3] or 255) / 255
   else
      self.colors_r[ind] = 1
      self.colors_g[ind] = 1
      self.colors_b[ind] = 1
   end
   self.z_orders[ind] = z_order
   self.drawables[ind] = params.drawables or nil
   self.drawables_after[ind] = params.drawables_after or nil
   self.updated = true
   return ind
end

function sparse_batch:remove_tile(ind)
   local tile = self.tiles[ind]
   if class.is_an(anim, tile) then
      table.insert(self.free_anims, tile)
   end
   if self.z_orders[ind] ~= nil then
      self.ordering:delete(self.z_orders[ind], ind)
   end

   self.tiles[ind] = nil
   self.xcoords[ind] = nil
   self.ycoords[ind] = nil
   self.xoffs[ind] = nil
   self.yoffs[ind] = nil
   self.rotations[ind] = nil
   self.colors_r[ind] = nil
   self.colors_g[ind] = nil
   self.colors_b[ind] = nil
   self.z_orders[ind] = nil
   self.drawables[ind] = nil
   self.drawables_after[ind] = nil

   self.updated = true
end

function sparse_batch:clear()
   for _, tile in pairs(self.tiles) do
      if class.is_an(anim, tile) then
         table.insert(self.free_anims, tile)
      end
   end

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
   self.drawables = {}
   self.drawables_after = {}
   self.batches = {}
   self.to_draw_inds = {}
   self.to_draw_drawables = {}
   self.ordering = SkipList:new()

   self.updated = true
end

function sparse_batch:set_tiles(tiles)
   self.tiles = tiles or {}
   self.updated = true
end

function sparse_batch:set_tile_offsets(ind, ox, oy)
   self.xoffs[ind] = ox
   self.yoffs[ind] = oy
   self.updated = true
end

function sparse_batch:update(dt)
   for _, t in pairs(self.tiles) do
      if class.is_an(anim, t) then
         local changed_frame = t:update(dt)
         self.updated = changed_frame or self.updated
      end
   end
   for _, drawable in ipairs(self.to_draw_drawables) do
      if drawable.update then
         drawable:update(dt)
      end
   end
end

function sparse_batch:draw(x, y, width, height)
   -- slight speedup
   local tw = self.tile_width
   local th = self.tile_height
   local offset_x = 0
   local offset_y = 0

   local xc = self.xcoords
   local yc = self.ycoords
   local xo = self.xoffs
   local yo = self.yoffs
   local rots = self.rotations

   local tx, ty, tdx, tdy = self.coords:find_bounds(x, y, width, height)

   if self.updated then
      for _, batch in ipairs(self.batches) do
         batch:clear()
      end

      self.to_draw_inds = {}
      self.to_draw_drawables = {}

      local batch = nil
      local batch_ind = 1
      local self_tiles = self.tiles
      local tiles = self.atlas.tiles
      local cr = self.colors_r
      local cg = self.colors_g
      local cb = self.colors_b
      local dr = self.drawables
      local dra = self.drawables_after

      for _, _, ind in self.ordering:iterate() do
         local tile = self_tiles[ind]

         if dr[ind] then
            if batch ~= nil then
               batch:setColor(1, 1, 1)
               batch:flush()
               batch = nil
            end
            for _, drawable in dr[ind]:iter() do
               self.to_draw_inds[#self.to_draw_inds+1] = ind
               self.to_draw_drawables[#self.to_draw_drawables+1] = drawable
            end
         end

         if class.is_an(IChipRenderable, tile) then -- TODO is this slow?
            -- This is a renderable object with custom logic (like
            -- PCCs). We have to stop drawing to the current sprite
            -- batch to draw it, in order to keep the Z ordering
            -- correct.
            if batch ~= nil then
               batch:setColor(1, 1, 1)
               batch:flush()
               batch = nil
            end
            self.to_draw_inds[#self.to_draw_inds+1] = ind
            self.to_draw_drawables[#self.to_draw_drawables+1] = tile
         elseif tile and tile ~= 0 then
            -- This is a reference to a tile in the sprite atlas.
            if batch == nil then
               -- Reuse a sprite batch from a previous update instead
               -- of allocating a new one every time
               batch = self.batches[batch_ind]

               if batch == nil then
                  -- No free sprite batch available in pool, make a new one
                  batch = love.graphics.newSpriteBatch(self.atlas.image)
                  self.batches[batch_ind] = batch
               end

               batch_ind = batch_ind + 1

               self.to_draw_inds[#self.to_draw_inds+1] = ind
               self.to_draw_drawables[#self.to_draw_drawables+1] = batch
            end

            local cx = xc[ind]
            local cy = yc[ind]
            if cx >= tx and cx < tdx and cy >= ty and cy < tdy then
               local i, j = self.coords:tile_to_screen(cx, cy)
               local px = i + xo[ind]
               local py = j + yo[ind]
               print("ADD", i, j)
               if cr[ind] then
                  batch:setColor(cr[ind], cg[ind], cb[ind])
               else
                  batch:setColor(1, 1, 1)
               end
               local tile_tbl = tiles[tile.image]
               if tile_tbl ~= nil then
                  --print(tile.image, tile_tbl.quad:getViewport())
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

         if dra[ind] then
            if batch ~= nil then
               batch:setColor(1, 1, 1)
               batch:flush()
               batch = nil
            end
            for _, drawable in dra[ind]:iter() do
               self.to_draw_inds[#self.to_draw_inds+1] = ind
               self.to_draw_drawables[#self.to_draw_drawables+1] = drawable
            end
         end
      end

      if batch ~= nil then
         batch:setColor(1, 1, 1)
         batch:flush()
      end

      self.updated = false
   end

   for idx = 1, #self.to_draw_inds do
      local ind = self.to_draw_inds[idx]
      local drawable = self.to_draw_drawables[idx]
      local i, j = self.coords:tile_to_screen(xc[ind], yc[ind])
      if drawable.draw then
         drawable:draw(x + offset_x + i + xo[ind],
                       y + offset_y + j + yo[ind],
                       nil,
                       nil,
                       false,
                       rots[ind])
      else
         print(x, y)
         love.graphics.draw(drawable,
                            x + offset_x,
                            y + offset_y)
      end
   end
end

return sparse_batch
