local Draw = require("api.Draw")

local atlas_batch = class.class("atlas_batch")

function atlas_batch:init(the_atlas)
   assert(class.is_an(require("internal.draw.atlas"), the_atlas))
   self.atlas = the_atlas
   self.batch = love.graphics.newSpriteBatch(the_atlas.image)
end

function atlas_batch:add(chip, x, y, width, height, color, centered, rotation)
   local tile = self.atlas.tiles[chip]
   if tile == nil then
      tile = self.atlas.tiles[chip .. "#default"]
   end

   local _, _, ttw, tth = tile.quad:getViewport()
   local sx = 1
   local sy = 1

   if color then
      self.batch:setColor(color[1] / 255, color[2] / 255, color[3] / 255)
   else
      self.batch:setColor(255, 255, 255)
   end

   if width then
      sx = width / ttw
   end
   if height then
      sy = height / height
   end

   local ox, oy
   if centered then
      ox = (width or ttw) / 2
      oy = (width or tth) / 2
   end

   self.batch:add(tile.quad,
                  x,
                  y + tile.offset_y,
                  rotation,
                  sx,
                  sy,
                  ox,
                  oy)
end

function atlas_batch:clear()
   self.batch:clear()
end

function atlas_batch:draw(x, y)
   self.batch:flush()
   Draw.set_color(255, 255, 255)
   love.graphics.draw(self.batch, x or 0, y or 0)
end

function atlas_batch:release()
   self.batch:release()
end

return atlas_batch
