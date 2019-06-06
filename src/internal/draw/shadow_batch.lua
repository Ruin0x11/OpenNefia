local IBatch = require("internal.draw.IBatch")
local atlas = require("internal.draw.atlas")
local draw = require("internal.draw")

local shadow_batch = class("shadow_batch", IBatch)

function shadow_batch:init(width, height, coords)
   self.width = width
   self.height = height
   self.coords = coords

   self.tiles = table.of(0, width * height)

   self.image = draw.load_image("graphic/temp/shadow.png")
   self.edge_image = draw.load_image("graphic/temp/shadow_edge.png")
   self.quad = {}
   self.edge_quad = {}

   local iw,ih
   iw = self.image:getWidth()
   ih = self.image:getHeight()
   for i=1,8 do
      for j=1,6 do
         self.quad[(j-1)*8+i] = love.graphics.newQuad((i-1) * 24, (j-1) * 24, 24, 24, iw, ih)
      end
   end

   iw = self.edge_image:getWidth()
   ih = self.edge_image:getHeight()
   for i=1,16 do
      self.edge_quad[i] = love.graphics.newQuad((i-1) * 48, 0, 48, 48, iw, ih)
   end

   self.batch = love.graphics.newSpriteBatch(self.image)
   self.edge_batch = love.graphics.newSpriteBatch(self.edge_image)

   self.updated = true
   self.tile_width = 48
   self.tile_height = 48
end

function shadow_batch:find_bounds(x, y)
   return -1, -1, draw.get_tiled_width() + 2, draw.get_tiled_height() + 2
end

function shadow_batch:set_tiles(tiles)
   self.tiles = tiles
   self.updated = true
end

function shadow_batch:update_tile(x, y, tile)
   if x >= 0 and y >= 0 and x < self.width and y < self.height then
      self.tiles[y*self.width+x+1] = tile
      self.updated = true
   end
end

function shadow_batch:add_one(shadow, x, y, batch)
   if shadow < 0 then
      return
   end

   local is_shadow = bit.band(shadow, 0x100) == 0x100

   if not is_shadow then
      -- Tile is lighted. Draw the fancy quarter-size shadow corners
      -- depending on the directions that border a shadow.
      --local d = deco[sl+1]
      --local deco2 = 0
      --return decot[sl+1]
      return
   end

   self.batch:add(self.quad[19], x, y)
   self.batch:add(self.quad[20], x+24, y)
   self.batch:add(self.quad[27], x, y+24)
   self.batch:add(self.quad[28], x+24, y+24)

   -- remove shadow flag
   local p2 = bit.band(bit.bnot(0x100), shadow)

   -- extract the cardinal part (NSEW)
   -- 00001111
   p2 = bit.band(p2, 0x0F)

   local tile = 0
   if p2 == 0xF then -- 1111
      -- All four cardinal directions border a shadow. Check the
      -- corner directions.

      -- extract the intercardinal part
      -- 11110000
      p2 = bit.band(p2, 0xF0)

      if     p2 == 0x70 then -- 0111     SW SE SW
         tile = 13
      elseif p2 == 0xD0 then -- 1101  NE SW    NW
         tile = 14
      elseif p2 == 0xB0 then -- 1011  NE    SE NW
         tile = 15
      elseif p2 == 0xE0 then -- 1110  NE SW SE
         tile = 16
      elseif p2 == 0xC0 then -- 1100  NE SW
         tile = 17
      elseif p2 == 0x30 then -- 0011        SE NW
         tile = 17
      end
   else
      tile = 13
   end

   -- return shadowmap[tile+1]
end

function shadow_batch:draw(x, y)
   -- slight speedup
   local batch = self.batch
   local tw = self.tile_width
   local th = self.tile_height

   local sx, sy, ox, oy = self.coords:get_start_offset(x, y, draw.get_width(), draw.get_height())
   ox = 48 - x % 48
   oy = 48 - y % 48

   if self.updated then
      local tx, ty, tdx, tdy = self.coords:find_bounds(0, 0, self.width, self.height)
      local self_tiles = self.tiles

      batch:clear()

      for y=ty,tdy do
         if y >= 0 and y <= self.height then
            for x=tx,tdx do
               if x >= 0 and x <= self.width then
                  local tile = self_tiles[x+1][y+1]
                  local i, j = self.coords:tile_to_screen(x - tx, y - ty)
                  self:add_one(tile, i, j)
               end
            end
         end
      end

      batch:flush()

      self.updated = false
   end

   love.graphics.setColor(0, 0, 0, 128 / 255)
   love.graphics.draw(batch, sx + ox - tw, sy + oy - th)
end

return shadow_batch
