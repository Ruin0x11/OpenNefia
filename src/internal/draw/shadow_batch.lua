local IBatch = require("internal.draw.IBatch")
local atlas = require("internal.draw.atlas")
local draw = require("internal.draw")

local shadow_batch = class.class("shadow_batch", IBatch)

local deco = {
--                 W           E            WE          S            S E          SW           SWE
-- 0000         0001         0010         0011         0100         0101         0110         0111
   { 0, 0,  0}, { 0, 1,  0}, { 1, 2,  0}, { 0, 0,  0}, { 1, 0,  0}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  00000000
   { 2, 1,  0}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  00001000 N
   {-1, 1,  0}, { 0, 1,  0}, { 1, 2,  0}, { 0, 2,  0}, { 1, 0,  0}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  00010000
   { 2, 1,  1}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  00011000 N
   {-1, 2,  0}, { 0, 1,  0}, { 1, 2,  0}, { 0, 2,  0}, { 1, 0,  0}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  00100000
   { 2, 1,  0}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  00101000 N
   {-1, 5,  0}, { 0, 1,  2}, { 1, 2,  1}, { 0, 2,  0}, { 1, 0,  2}, { 0, 0,  2}, {-1, 21, 0}, {-1, 30, 0},  --  00110000
   { 2, 1,  1}, {-1, 20, 0}, { 2, 2,  1}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  00111000 N
   {-1, 3,  0}, { 0, 1,  0}, { 1, 2,  0}, { 0, 2,  0}, { 1, 0,  0}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  01000000
   { 2, 1,  0}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  01001000 N
   {-1, 9,  0}, { 0, 1,  0}, { 1, 2,  1}, { 0, 2,  0}, { 1, 0,  3}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  01010000
   { 2, 1,  0}, {-1, 20, 0}, { 2, 2,  0}, { 0, 1,  0}, { 2, 0,  0}, { 0, 1,  0}, {-1, 31, 0}, { 3, 1,  0},  --  01011000 N
   {-1, 7,  0}, { 0, 1,  2}, { 1, 2,  0}, { 0, 2,  0}, { 1, 0,  0}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  01100000
   { 2, 1,  3}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  01101000 N
   {-1, -1, 0}, { 0, 1,  2}, { 1, 2,  1}, { 0, 2,  0}, { 1, 0,  0}, { 0, 0,  2}, {-1, 21, 0}, {-1, 30, 0},  --  01110000
   { 2, 1,  0}, {-1, 20, 0}, { 2, 2,  1}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  01111000 N
   {-1, 4,  0}, { 0, 1,  0}, { 1, 2,  0}, { 0, 2,  0}, { 1, 0,  0}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  10000000
   { 2, 1,  0}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  10001000 N
   {-1, 8,  0}, { 0, 1,  4}, { 1, 2,  0}, { 0, 2,  0}, { 1, 0,  0}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  10010000
   { 2, 1,  1}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  10011000 N
   {-1, 10, 0}, { 0, 1,  0}, { 1, 2,  4}, { 0, 2,  0}, { 1, 0,  2}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  10100000
   { 2, 1,  0}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  10101000 N
   {-1, -1, 0}, { 0, 1,  0}, { 1, 2,  8}, { 0, 2,  0}, { 1, 0,  2}, { 0, 0,  2}, {-1, 21, 0}, {-1, 30, 0},  --  10110000
   { 2, 1,  1}, {-1, 20, 0}, { 2, 2,  1}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  10111000 N
   {-1, 6,  0}, { 0, 1,  0}, { 1, 2,  4}, { 0, 2,  4}, { 1, 0,  3}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  11000000
   { 2, 1,  3}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  3}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  11001000 N
   {-1, -1, 0}, { 0, 1,  4}, { 1, 2,  0}, { 0, 2,  0}, { 1, 0,  3}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  11010000
   { 2, 1,  0}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  3}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  11011000 N
   {-1, -1, 0}, { 0, 1,  0}, { 1, 2,  4}, { 0, 2,  0}, { 1, 0,  0}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  11100000
   { 2, 1,  3}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  3}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  --  11101000 N
   {-1, -1, 0}, { 0, 1, 10}, { 1, 2,  8}, { 0, 2,  4}, { 1, 0,  7}, { 0, 0,  0}, {-1, 21, 0}, {-1, 30, 0},  --  11110000
   { 2, 1,  0}, {-1, 20, 0}, { 2, 2,  0}, {-1, 33, 0}, { 2, 0,  0}, {-1, 32, 0}, {-1, 31, 0}, { 3, 1,  0},  -- 100000000
};

local shadowmap = {
    0, 9, 10, 5, 12, 7, 0, 1, 11, 0, 6, 3, 8, 4, 2, 0, 0,
};

local function generate_deco()
   deco[0] = {}
   deco[1] = {}
   deco[2] = {}
   for i=0,15 do
      deco[0][i * 0x10 + 0x01] = 0
      deco[1][i * 0x10 + 0x01] = 1
   end
end

function shadow_batch:init(width, height, coords)
   self.width = width
   self.height = height
   self.coords = coords

   self.tiles = table.of_2d(0, width + 4, height + 4, true)

   -- self.image = draw.load_image("graphic/temp/shadow.png")
   -- self.edge_image = draw.load_image("graphic/temp/shadow_edge.png")
   self.image = draw.load_image("graphic/temp/shadow_nonalpha.bmp")
   self.edge_image = draw.load_image("graphic/temp/shadow_edges_nonalpha.bmp")
   self.quad = {}
   self.corner_quad = {}
   self.edge_quad = {}

   local iw,ih
   iw = self.image:getWidth()
   ih = self.image:getHeight()
   for i=1,8 do
      self.quad[i] = {}
      for j=1,6 do
         self.quad[i][j] = love.graphics.newQuad((i-1) * 24, (j-1) * 24, 24, 24, iw, ih)
      end
   end
   for i=1,4 do
      for j=1,3 do
         self.corner_quad[(j-1)*4+i] = love.graphics.newQuad((i-1) * 48, (j-1) * 48, 48, 48, iw, ih)
      end
   end

   iw = self.edge_image:getWidth()
   ih = self.edge_image:getHeight()
   for i=1,17 do
      self.edge_quad[i] = love.graphics.newQuad((i-1) * 48, 0, 48, 48, iw, ih)
   end

   self.batch = love.graphics.newSpriteBatch(self.image)
   self.edge_batch = love.graphics.newSpriteBatch(self.edge_image)

   self.updated = true
   self.tile_width = 48
   self.tile_height = 48

   self.light = 50
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

function shadow_batch:add_one_deco(d, x, y)
   if d == 1 then
      -- upper-left inner
      self.batch:add(self.quad[8][2], x, y)
   elseif d == 2 then
      -- lower-right inner
      self.batch:add(self.quad[7][1], x + 24, y + 24)
   elseif d == 3 then
      -- lower-left inner
      self.batch:add(self.quad[8][1], x, y + 24)
   elseif d == 4 then
      -- upper-right inner
      self.batch:add(self.quad[7][2], x + 24, y)
   elseif d == 5 then
      -- upper-left inner
      -- lower-right inner
      self.batch:add(self.quad[7][1], x + 24, y + 24)
      self.batch:add(self.quad[8][2], x, y)
   elseif d == 6 then
      -- upper-right inner
      -- lower-left inner
      self.batch:add(self.quad[8][1], x, y + 24)
      self.batch:add(self.quad[7][2], x + 24, y)
   elseif d == 7 then
      -- lower-right inner
      -- lower-left inner
      self.batch:add(self.quad[8][1], x, y + 24)
      self.batch:add(self.quad[7][1], x + 24, y + 24)
   elseif d == 8 then
      -- upper-right inner
      -- upper-left inner
      self.batch:add(self.quad[8][2], x, y)
      self.batch:add(self.quad[7][2], x + 24, y)
   elseif d == 9 then
      -- upper-left inner
      -- lower-left inner
      self.batch:add(self.quad[8][2], x, y)
      self.batch:add(self.quad[8][1], x, y + 24)
   elseif d == 10 then
      -- upper-right inner
      -- lower-right inner
      self.batch:add(self.quad[7][2], x + 24, y)
      self.batch:add(self.quad[7][1], x + 24, y + 24)

   elseif d == 20 then
      -- left border
      -- right border
      self.batch:add(self.quad[1][3], x, y)
      self.batch:add(self.quad[1][4], x, y + 24)
      self.batch:add(self.quad[6][3], x + 24, y)
      self.batch:add(self.quad[6][4], x + 24, y + 24)
   elseif d == 21 then
      -- top border
      -- bottom border
      self.batch:add(self.quad[3][1], x, y)
      self.batch:add(self.quad[4][1], x + 24, y)
      self.batch:add(self.quad[3][6], x, y + 24)
      self.batch:add(self.quad[4][6], x + 24, y + 24)

   elseif d == 30 then
      -- right outer dart
      self.batch:add(self.quad[1][1], x, y)
      self.batch:add(self.quad[2][1], x + 24, y)
      self.batch:add(self.quad[1][6], x, y + 24)
      self.batch:add(self.quad[2][6], x + 24, y + 24)

   elseif d == 31 then
      -- left outer dart
      self.batch:add(self.quad[5][1], x, y)
      self.batch:add(self.quad[6][1], x + 24, y)
      self.batch:add(self.quad[5][6], x, y + 24)
      self.batch:add(self.quad[6][6], x + 24, y + 24)

   elseif d == 32 then
      self.batch:add(self.quad[1][1], x, y)
      -- upper outer dart
      self.batch:add(self.quad[1][2], x, y + 24)
      self.batch:add(self.quad[6][1], x + 24, y)
      self.batch:add(self.quad[6][2], x + 24, y + 24)
   elseif d == 33 then
      -- lower outer dart
      self.batch:add(self.quad[1][5], x, y)
      self.batch:add(self.quad[1][6], x, y + 24)
      self.batch:add(self.quad[6][5], x + 24, y)
      self.batch:add(self.quad[6][6], x + 24, y + 24)
   end
end

function shadow_batch:add_deco(shadow, x, y)
   local d0 = deco[shadow+1][1]
   local d1 = deco[shadow+1][2]

   if d0 == -1 then
      self:add_one_deco(d1, x, y)
   else
      -- d0, d1 is x, y index into shadow image by size 48
      self.batch:add(self.corner_quad[d1*4+d0+1], x, y)
   end

   local d2 = deco[shadow+1][3]

   if d2 ~= 0 then
      self:add_one_deco(d2, x, y)
   end
end

function shadow_batch:add_one(shadow, x, y, batch)
   if shadow <= 0 then
      return
   end

   local is_shadow = bit.band(shadow, 0x100) == 0x100

   if not is_shadow then
      -- Tile is lighted. Draw the fancy quarter-size shadow corners
      -- depending on the directions that border a shadow.
      self:add_deco(shadow, x, y)
      return
   end

   -- remove shadow flag
   local p2 = bit.band(bit.bnot(0x100), shadow)

   -- extract the cardinal part (NSEW)
   -- 00001111
   local p3 = bit.band(p2, 0x0F)

   local tile = 0
   if p3 == 0x0F then
      -- All four cardinal directions border a shadow. Check the
      -- corner directions.

      -- extract the intercardinal part
      -- 11110000
      p3 = bit.band(p2, 0xF0)

      if     p3 == 0x70 then -- 0111     SW SE SW
         tile = 13
      elseif p3 == 0xD0 then -- 1101  NE SW    NW
         tile = 14
      elseif p3 == 0xB0 then -- 1011  NE    SE NW
         tile = 15
      elseif p3 == 0xE0 then -- 1110  NE SW SE
         tile = 16
      elseif p3 == 0xC0 then -- 1100  NE SW
         tile = 17
      elseif p3 == 0x30 then -- 0011        SE NW
         tile = 17
      end
   else
      tile = shadowmap[p3+1]
   end

   if tile == 0 then
      self.batch:add(self.corner_quad[12], x, y)
   else
      self.edge_batch:add(self.edge_quad[tile], x, y)
   end
end

function shadow_batch:draw(x, y)
   -- slight speedup
   local tw = self.tile_width
   local th = self.tile_height

   local sx, sy, ox, oy = self.coords:get_start_offset(x, y, draw.get_width(), draw.get_height())

   sx = -sx
   sy = -sy

   if x < 0 then
      ox = 48
   elseif x > 0 then
      if ox == 48 then
         ox = 0
      end
   end
   if y < 0 then
      oy = 48
   elseif y > 0 then
      if oy == 48 then
         oy = 0
      end
   end

   ox = ox - 48
   oy = oy - 48

   if self.updated then
      local tx, ty, tdx, tdy = self.coords:find_bounds(0, 0, self.width, self.height)
      local self_tiles = self.tiles

      self.batch:clear()
      self.edge_batch:clear()

      for y=ty-1,tdy do
         if y >= -1 and y <= self.height then
            for x=tx-1,tdx do
               if x >= -1 and x <= self.width then
                  local tile = self_tiles[x+1][y+1]
                  local i, j = self.coords:tile_to_screen(x - tx, y - ty)
                  self:add_one(tile, i, j)
               end
            end
         end
      end

      self.batch:flush()
      self.edge_batch:flush()

      self.updated = false
   end

   draw.set_color(255, 255, 255, self.light)
   love.graphics.setBlendMode("subtract")
   love.graphics.draw(self.batch, sx + ox - tw, sy + oy - th)
   love.graphics.draw(self.edge_batch, sx + ox - tw, sy + oy - th)
   love.graphics.setBlendMode("alpha")
end

return shadow_batch
