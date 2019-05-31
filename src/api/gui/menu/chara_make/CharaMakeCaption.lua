local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")

local CharaMakeCaption = class("CharaMakeCaption", IUiElement)

function make_caption(width)
   local image = Draw.load_image("graphic/temp/caption.bmp")
   local quad = {}
   local iw = image:getWidth()
   local ih = image:getHeight()

   quad[1] = love.graphics.newQuad(0, 0, 128, 3, iw, ih)
   quad[2] = love.graphics.newQuad(0, 3, 128, 22, iw, ih)
   quad[3] = love.graphics.newQuad(0, 0, 128, 2, iw, ih)

   quad[4] = love.graphics.newQuad(0, 0, width % 128, 3, iw, ih)
   quad[5] = love.graphics.newQuad(0, 3, width % 128, 22, iw, ih)
   quad[6] = love.graphics.newQuad(0, 0, width % 128, 2, iw, ih)

   return { image = image, quad = quad }
end

function CharaMakeCaption:init(x, y, caption)
   self.x = x
   self.y = y
   self.width = 760
   self.height = 24
   self.caption = caption
end

function CharaMakeCaption:relayout()
   self.width = math.min(Draw.text_width(self.caption) + 45, 760)
   self.image = make_caption(self.width)
end

function CharaMakeCaption:update()
end

function CharaMakeCaption:draw()
   Draw.set_font(16) -- 16 - en * 2

   local step = self.width / 128 + 1
   for i=1,step do
      local q
      if i == self.width / 128 then
         step = self.width % 128
         q = 3
      else
         step = 128
         q = 0
      end

      Draw.image_region(self.image.image, self.image.quad[1 + q], i * 128 + self.x, self.y)
      Draw.image_region(self.image.image, self.image.quad[2 + q], i * 128 + self.x, self.y + 2)
      Draw.image_region(self.image.image, self.image.quad[3 + q], i * 128 + self.x, self.y + 22)
   end

   Draw.text(self.caption, self.x + 18, self.y + 4, {245, 245, 245}) -- y + vfix + 4
end

return CharaMakeCaption
