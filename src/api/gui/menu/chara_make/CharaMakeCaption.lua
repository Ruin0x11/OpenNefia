local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")

local CharaMakeCaption = class("CharaMakeCaption", {IUiElement, ISettable})

local function make_caption(width)
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

function CharaMakeCaption:init(caption)
   self.width = 760
   self.height = 24

   self.caption = caption or ""
end

function CharaMakeCaption:set_data(caption)
   self.caption = caption or self.caption
   self:relayout()
end

function CharaMakeCaption:relayout(x, y)
   self.x = x or self.x
   self.y = y or self.y

   local width = math.min(Draw.text_width(self.caption) + 45, 760)
   local regen = self.image == nil or width % 128 ~= self.width % 128

   self.width = width

   if regen then
      self.image = make_caption(self.width)
   end
end

function CharaMakeCaption:update()
end

function CharaMakeCaption:draw()
   Draw.set_font(16) -- 16 - en * 2

   local step = self.width / 128
   for i=0,step do
      local q
      if i == self.width / 128 - 1 then
         step = self.width % 128
         q = 3
      else
         step = 128
         q = 0
      end

      Draw.image_region(self.image.image, self.image.quad[1 + q], i * 128 + self.x, self.y, nil, nil, {255, 255, 255})
      Draw.image_region(self.image.image, self.image.quad[2 + q], i * 128 + self.x, self.y + 2, nil, nil, {255, 255, 255})
      Draw.image_region(self.image.image, self.image.quad[3 + q], i * 128 + self.x, self.y + 22, nil, nil, {255, 255, 255})
   end

   Draw.text(self.caption, self.x + 18, self.y + 4, {245, 245, 245}) -- y + vfix + 4
end

return CharaMakeCaption
