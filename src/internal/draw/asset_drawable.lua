local draw = require("internal.draw")

local asset_drawable = class.class("asset_drawable")

function asset_drawable:init(data_inst)
   if type(data_inst) == "string" then
      data_inst = { image = data_inst }
   end

   if type(data_inst) == "userdata" and data_inst.typeOf and data_inst:typeOf("Image") then
      self.image = data_inst
   else
      self.image = draw.load_image(data_inst.image)
   end

   self.quads = {}
   self.bar_quads = {}

   local count_x = data_inst.count_x or 1
   local count_y = data_inst.count_y or 1
   if count_x ~= 1 or count_y ~= 1 then
      local iw = self.image:getWidth()
      local ih = self.image:getHeight()
      local w = iw / count_x
      local h = ih / count_y
      for j=1,count_y do
         for i=1,count_x do
            self.quads[i] = love.graphics.newQuad(w * (i - 1),
                                                  h * (j - 1),
                                                  w, h, iw, ih)
         end
      end
   end
end

function asset_drawable:get_width()
   return self.image:getWidth()
end

function asset_drawable:get_height()
   return self.image:getHeight()
end

function asset_drawable:draw(x, y, width, height, color, centered, rotation)
   draw.image(self.image, x, y, width, height, color, centered, rotation)
end

function asset_drawable:draw_region(quad, x, y, width, height, color, centered, rotation)
   if quad < 1 or quad > #self.quads then
      error(string.format("Quad ID %d is not in range 1,%d", quad, #self.quads))
      return
   end
   draw.image_region(self.image, self.quads[quad], x, y, width, height, color, centered, rotation)
end

function asset_drawable:draw_stretched(x, y, tx, ty, color, centered, rotation)
   draw.image_stretched(self.image, x, y, tx, ty, color, centered, rotation)
end

function asset_drawable:draw_region_stretched(quad, x, y, tx, ty, color, centered, rotation)
   if quad < 1 or quad > #self.quads then
      error(string.format("Quad ID %d is not in range 1,%d", quad, #self.quads))
      return
   end
   draw.image_region_stretched(self.image, self.quads[quad], x, y, tx, ty, color, centered, rotation)
end

function asset_drawable:draw_bar(x, y, width)
   local iw = self:get_width()
   local ih = self:get_height()

   local last_width = width % iw
   local last_quad = self.bar_quads[last_width]
   if last_quad == nil then
      self.bar_quads = {} -- TODO
      self.bar_quads[last_width] = love.graphics.newQuad(0, 0, last_width, ih, iw, ih)
      last_quad = self.bar_quads[last_width]
   end

   local step = math.floor(width / iw)
   for i=0,step do
      if i == step - 1 then
         step = width % iw
         draw.image_region(self.image, last_quad, i * iw + x, y)
      else
         step = iw
         draw.image(self.image, i * iw + x, y)
      end
   end
end

function asset_drawable:draw_percentage_bar(x, y, width)
   local iw = self:get_width()
   local ih = self:get_height()

   local last_width = width % iw;
   local last_quad = self.bar_quads[last_width]
   if last_quad == nil then
      self.bar_quads = {} -- TODO
      self.bar_quads[last_width] = love.graphics.newQuad(iw - width, 0, last_width, ih, iw, ih)
      last_quad = self.bar_quads[last_width]
   end

   draw.image_region(self.image, last_quad, x, y)
end

function asset_drawable:release()
   for _, q in ipairs(self.quads) do
      q:release()
   end
   self.image:release()
end

return asset_drawable
