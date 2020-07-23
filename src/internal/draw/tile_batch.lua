local IBatch = require("internal.draw.IBatch")
local Draw = require("api.Draw")
local tile_batch = class.class("tile_batch", IBatch)

function tile_batch:init(width, height, offset_x, offset_y)
   self.width = width
   self.height = height
   self.tile_width = nil
   self.tile_height = nil

   self.shadow = {5, 5, 5}

   self.tiles = {}
   self.batch = nil
   self.updated = true
end

function tile_batch:on_theme_switched(atlas, coords)
   self.atlas = atlas
   self.coords = coords
   self.batch = love.graphics.newSpriteBatch(atlas.image)
   self.tiles = {}
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
      local t = self.tiles[y*self.width+x+1]
      if t == nil or t.tile_id ~= tile then
         self.tiles[y*self.width+x+1] = self.atlas:make_anim(tile)
      end
      self.updated = true
   end
end

function tile_batch:update(dt)
   for i=1,self.width * self.height do
      local t = self.tiles[i]
      if t then
         local changed_frame = t:update(dt)
         self.updated = changed_frame or self.updated
      end
   end
end

function tile_batch:draw(x, y)
   -- slight speedup
   local batch = self.batch
   local tw = self.tile_width
   local th = self.tile_height

   local sx, sy, ox, oy = self.coords:get_start_offset(x, y, Draw.get_width(), Draw.get_height())

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
                  if tile ~= nil then
                     local i, j = self.coords:tile_to_screen(x - tx, y - ty)
                     local tile_data = tiles[tile.image]
                     assert(tile_data, tostring(tile.image))
                     batch:add(tile_data.quad, i, j + tile_data.offset_y)
                  end
               end
            end
         end
      end

      batch:flush()

      self.updated = false
   end

   Draw.set_color(255, 255, 255)
   love.graphics.draw(batch, sx + ox - tw, sy + oy - th)

   -- TODO: The original HSP code uses the gfdec2 function. gfdec2
   -- decrements colors but prevents them from reaching a 0 value, so
   -- the colors here are inaccurate.
   Draw.set_blend_mode("subtract")
   Draw.set_color(self.shadow[1], self.shadow[2], self.shadow[3], 108)
   Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height())
   Draw.set_blend_mode("alpha")
end

return tile_batch
