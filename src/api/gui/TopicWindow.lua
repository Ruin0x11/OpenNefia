local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")

local TopicWindow = class("TopicWindow", IUiElement)

local function gen_data(width, height, frame_style, fill_style)
   local img = Draw.load_image("graphic/temp/window.bmp")
   local iw = img:getWidth()
   local ih = img:getHeight()
   local quad = {}

   quad["fill"] = love.graphics.newQuad(24, 24, 228, 144, iw, ih)


   local frame_img = Draw.load_image(string.format("graphic/temp/window%d.bmp", frame_style))
   local fw = frame_img:getWidth()
   local fh = frame_img:getHeight()
   local frame_quad = {}

   frame_quad["top_mid"] = love.graphics.newQuad(16, 0, 16, 16, fw, fh)
   frame_quad["bottom_mid"] = love.graphics.newQuad(16, 32, 16, 16, fw, fh)
   frame_quad["top_mid2"] = love.graphics.newQuad(16, 0, width % 16, 16, fw, fh)
   frame_quad["bottom_mid2"] = love.graphics.newQuad(16, 32, width % 16, 16, fw, fh)
   frame_quad["left_mid"] = love.graphics.newQuad(0, 16, 16, 16, fw, fh)
   frame_quad["right_mid"] = love.graphics.newQuad(32, 16, 16, 16, fw, fh)
   frame_quad["left_mid2"] = love.graphics.newQuad(0, 16, 16, height % 16, fw, fh)
   frame_quad["right_mid2"] = love.graphics.newQuad(32, 16, 16, height % 16, fw, fh)
   frame_quad["top_left"] = love.graphics.newQuad(0, 0, 16, 16, fw, fh)
   frame_quad["bottom_left"] = love.graphics.newQuad(0, 32, 16, 16, fw, fh)
   frame_quad["top_right"] = love.graphics.newQuad(32, 0, 16, 16, fw, fh)
   frame_quad["bottom_right"] = love.graphics.newQuad(32, 32, 16, 16, fw, fh)

   return {
      window = { quad = quad, batch = img },
      frame = { quad = frame_quad, batch = love.graphics.newSpriteBatch(frame_img, fw * fh) },
   }
end

function TopicWindow:init(x, y, width, height, frame_style, fill_style)
   self.width = math.max(width, 32)
   self.height = math.max(height, 24)

   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.frame_style = frame_style
   self.fill_style = fill_style
end

function TopicWindow:draw()
   local x = self.x
   local y = self.y
   local width = self.width
   local height = self.height
   local fill_style = self.fill_style
   local color = {255, 255, 255}

   if fill_style == 6 then
      Draw.image(self.data.window.batch, x + width / 2, y + height / 2, width - 4, height - 4, {255, 255, 255, 180})
   elseif fill_style ~= 5 then
      local rect = true
      if fill_style == 0 then
         rect = false
      elseif fill_style == 1 then
         color = {255-195, 255-205, 255-195}
      elseif fill_style == 2 then
         color = {255-210, 255-215, 255-205}
      elseif fill_style == 3 then
         color = {255-10, 255-13, 255-16}
      elseif fill_style == 4 then
         color = {255-195, 255-205, 255-195}
      end

      Draw.image_region(self.data.window.batch, self.data.window.quad["fill"], x + 4, y + 4, width - 6, height - 8, color)
      -- if rect then
      --    Draw.filled_rect(x + 4, y + 4, width - 4, height - 4, )
      -- end
   end

   Draw.set_color()
   Draw.image(self.data.frame.batch)

   if fill_style == 5 then
      Draw.image(self.data.window.batch, x + 2, y + 2, width - 4, height - 5, {255-195, 255-205, 255-195})
      -- Draw.filled_rect(x + 2, y + 2, width - 4, height - 5, {255-195, 255-205, 255-195})
   end
end

function TopicWindow:relayout()
   self.data = gen_data(self.width, self.height, self.frame_style, self.fill_style)

   local x = self.x
   local y = self.y
   local width = self.width
   local height = self.height
   local fill_style = self.fill_style

   Draw.set_color()

   local frame = self.data.frame
   for i=0, width / 16 - 2 do
      frame.batch:add(frame.quad["top_mid"], i * 16 + x + 16, y)
      frame.batch:add(frame.quad["bottom_mid"], i * 16 + x + 16, y + height - 16)
   end

   local x_inner = x + width / 16 * 16 - 16
   local y_inner = y + height / 16 * 16 - 16

   frame.batch:add(frame.quad["top_mid2"], x_inner, y)
   frame.batch:add(frame.quad["bottom_mid2"], x_inner, y + height - 16)

   for i=0, height / 16 - 2 do
      frame.batch:add(frame.quad["left_mid"], x, i * 16 + y + 16)
      frame.batch:add(frame.quad["right_mid"], x + width - 16, i * 16 + y + 16)
   end

   frame.batch:add(frame.quad["left_mid2"], x, y_inner)
   frame.batch:add(frame.quad["right_mid2"], x + width - 16, y_inner)

   frame.batch:add(frame.quad["top_left"], x, y)
   frame.batch:add(frame.quad["bottom_left"], x, y + height - 16)
   frame.batch:add(frame.quad["top_right"], x + width - 16, y)
   frame.batch:add(frame.quad["bottom_right"], x + width - 16, y + height - 16)
end

function TopicWindow:update()
end

return TopicWindow
