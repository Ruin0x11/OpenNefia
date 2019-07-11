local asset_drawable = require("internal.draw.asset_drawable")
local binpack = require("thirdparty.binpack")

local atlas = class.class("atlas")

function atlas:init(tile_count_x, tile_count_y, tile_width, tile_height)
   self.tile_width = tile_width
   self.tile_height = tile_height
   self.tile_count_x = tile_count_x
   self.tile_count_y = tile_count_y
   self.tiles = {}
   self.image = nil
   self.batch = nil
   self.image_width = self.tile_width * self.tile_count_x
   self.image_height = self.tile_height * self.tile_count_y
   self.binpack = binpack:new(self.image_width, self.image_height)

   -- blank fallback in case of missing filepath.
   local fallback_data = love.image.newImageData(self.tile_width, self.tile_height)
   self.fallback = love.graphics.newImage(fallback_data)
end

function atlas:insert_tile(id, frame, filepath)
   local full_id = id .. "#" .. tostring(frame)
   if self.tiles[full_id] then
      error("already loaded")
   end

   local tile = love.graphics.newImage(filepath)
   assert(tile, filepath)

   local rect = self.binpack:insert(tile:getWidth(), tile:getHeight())
   assert(rect, filepath)

   if self.coords then
      self.coords:load_tile(tile, rect.x, rect.y)
   else
      love.graphics.draw(tile, rect.x, rect.y)
   end

   local quad = love.graphics.newQuad(rect.x,
                                      rect.y,
                                      self.tile_width,
                                      self.tile_height,
                                      self.image_width,
                                      self.image_height)

   self.tiles[full_id] = quad

   tile:release()
end

function atlas:load_one(proto)
   local id = proto._id
   local images = proto.image
   if type(images) == "string" then
      images = {images}
   end

   assert(type(images) == "table", inspect(proto))

   for i, v in ipairs(images) do
      self:insert_tile(id, i, v)
   end
end

function atlas:load(proto_iter, coords)
   -- self.coords = coords -- TODO

   self.tiles = {}

   local image_width = self.tile_width * self.tile_count_x
   local image_height = self.tile_height * self.tile_count_y

   local canvas = love.graphics.newCanvas(image_width, image_height)
   love.graphics.setCanvas(canvas)

   for _, proto in proto_iter:unwrap() do
      self:load_one(proto)
   end

   love.graphics.setCanvas()

   self.image = love.graphics.newImage(canvas:newImageData())
   canvas:release()

   self.batch = love.graphics.newSpriteBatch(self.image)
end

function atlas:copy_tile_image(tile)
   local quad = self.tiles[tile]
   local image

   if quad then
      love.graphics.setColor(1, 1, 1) -- TODO allow change?

      image = love.graphics.newCanvas(self.tile_width, self.tile_height)
      love.graphics.setCanvas(image)

      love.graphics.draw(self.image, quad, 0, 0)

      love.graphics.setCanvas()
      image = love.graphics.newImage(image:newImageData())
   else
      image = self.fallback
   end

   return asset_drawable:new(image)
end

return atlas
