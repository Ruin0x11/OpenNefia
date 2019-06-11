local Log = require("api.Log")
local atlas = class("atlas")

function atlas:init(tile_count_x, tile_count_y, tile_width, tile_height)
   self.tile_width = tile_width
   self.tile_height = tile_height
   self.tile_count_x = tile_count_x
   self.tile_count_y = tile_count_y
   self.image_width = tile_width * tile_count_x
   self.image_height = tile_height * tile_count_y
   self.tiles = {}
   self.image = nil
   self.batch = nil
end

function atlas:load(files, coords)
   self.tiles = {}

   local canvas = love.graphics.newCanvas(self.image_width, self.image_height)
   love.graphics.setCanvas(canvas)

   for i, filepath in ipairs(files) do
      i = i - 1
      -- assert(i < self.tile_count_x * self.tile_count_y)
      if i >= self.tile_count_x * self.tile_count_y then
         Log.warn("Cannot load past " .. i .. " tiles.")
         break
      end

      local id = i + 1
      -- HACK
      if type(filepath) == "table" then
         -- data prototype
         id = filepath._id
         filepath = filepath.image
         if type(filepath) == "table" then
            -- first animation frame
            filepath = filepath[1]
         end
      end

      local tile = love.graphics.newImage(filepath)
      local x = (i % self.tile_count_x) * self.tile_width
      local y = (math.floor(i / self.tile_count_y)) * self.tile_height

      self.tiles[id] = love.graphics.newQuad(x, y, self.tile_width, self.tile_height, self.image_width, self.image_height)

      if coords then
         coords:load_tile(tile, x, y)
      else
         love.graphics.draw(tile, x, y)
      end

      tile:release()
   end

   love.graphics.setCanvas()

   self.image = love.graphics.newImage(canvas:newImageData())
   canvas:release()
   canvas = nil

   self.batch = love.graphics.newSpriteBatch(self.image)
end

function atlas:copy_tile_image(tile)
   local quad = self.tiles[tile]
   local image

   if quad then
      love.graphics.setColor(1, 1, 1) -- TODO allow change?

      image = love.graphics.newCanvas(self.tile_width, self.tile_height)
      love.graphics.setCanvas(image)

      love.graphics.draw(self.image, quad, x, y)

      love.graphics.setCanvas()
      image = love.graphics.newImage(image:newImageData())
   end

   return image
end

return atlas
