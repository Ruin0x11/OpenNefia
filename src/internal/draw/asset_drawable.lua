local Draw = require("api.Draw")
local asset_instance = require("internal.draw.asset_instance")
local bmp_convert = require("internal.bmp_convert")

local asset_drawable = class.class("asset_drawable")

local function crop(proto)
   local base = bmp_convert.load_image(proto.source, proto.key_color)

   local quad = love.graphics.newQuad(proto.x, proto.y, proto.width, proto.height,
                                      base:getWidth(), base:getHeight())
   assert(proto.width > 0, inspect(proto))
   local canvas = love.graphics.newCanvas(proto.width, proto.height)
   love.graphics.setCanvas(canvas)

   love.graphics.draw(base, quad, 0, 0)

   love.graphics.setCanvas()
   local image = love.graphics.newImage(canvas:newImageData())

   quad:release()
   canvas:release()

   return image
end

local function load_image_region(proto)
   love.graphics.setColor(1, 1, 1)

   if proto.image then
      return bmp_convert.load_image(proto.image, proto.key_color)
   end

   if proto.source then
      return crop(proto)
   end

   error(("invalid image asset (%s): must contain {image} or {source,x,y,width,height}"):format(proto._id))
end

function asset_drawable:init(proto)
   self.image = load_image_region(proto)

   self.quads = {}
   self.bar_quads = {}

   local iw = self.image:getWidth()
   local ih = self.image:getHeight()

   local count_x = proto.count_x or 1
   local count_y = proto.count_y or 1
   if count_x ~= 1 or count_y ~= 1 then
      local w = iw / count_x
      local h = ih / count_y

      local q = 1
      for j=1,count_y do
         for i=1,count_x do
            self.quads[q] = love.graphics.newQuad(w * (i - 1),
                                                  h * (j - 1),
                                                  w, h, iw, ih)
            q = q + 1
         end
      end
   end
   self.count_x = count_x
   self.count_y = count_y

   self.regions = proto.regions

   if type(self.regions) == "table" then
      for k, v in pairs(self.regions) do
         self.quads[k] = love.graphics.newQuad(v[1], v[2], v[3], v[4], self.image:getWidth(), self.image:getHeight())
      end
   end
end

function asset_drawable:make_instance(width, height)
   return asset_instance:new(self, width, height)
end

function asset_drawable:get_width()
   return self.image:getWidth()
end

function asset_drawable:get_height()
   return self.image:getHeight()
end

function asset_drawable:draw(x, y, width, height, color, centered, rotation)
   Draw.image(self.image, x, y, width, height, color, centered, rotation)
end

function asset_drawable:draw_region(quad, x, y, width, height, color, centered, rotation)
   if (table.count(self.quads) == 0 or ((width or height) and type(self.regions) == "function")) then
      error("Can't draw this asset dynamically; use make_instance() first")
   end

   if not self.quads[quad] then
      error(string.format("Quad ID '%s' not found", tostring(quad)))
      return
   end
   Draw.image_region(self.image, self.quads[quad], x, y, width, height, color, centered, rotation)
end

function asset_drawable:draw_stretched(x, y, tx, ty, color, centered, rotation)
   Draw.image_stretched(self.image, x, y, tx, ty, color, centered, rotation)
end

function asset_drawable:draw_region_stretched(quad, x, y, tx, ty, color, centered, rotation)
   if not self.quads[quad] then
      error(string.format("Quad ID '%s' not found", tostring(quad)))
      return
   end
   Draw.image_region_stretched(self.image, self.quads[quad], x, y, tx, ty, color, centered, rotation)
end

function asset_drawable:draw_tiled()
   local iw = self:get_width()
   local ih = self:get_height()

   for j = 0, Draw.get_height() / iw do
      for i = 0, Draw.get_width() / ih do
         self:draw(i * iw, j * ih)
      end
   end
end

function asset_drawable:release()
   for _, quad in pairs(self.quads) do
      quad:release()
   end
   self.quads = {}
   self.image:release()
   self.image = nil
end

return asset_drawable
