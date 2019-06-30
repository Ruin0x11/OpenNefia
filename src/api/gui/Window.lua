local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")

local Window = class.class("Window", IUiElement)

local data

local function init_data()
   local img = Draw.load_image("graphic/temp/window.bmp")
   local quad = {}
   local iw = img:getWidth()
   local ih = img:getHeight()

   img:setFilter("nearest", "linear")

   quad["top_left"] = love.graphics.newQuad(0, 0, 64, 48, iw, ih)
   quad["top_right"] = love.graphics.newQuad(208, 0, 56, 48, iw, ih)
   quad["bottom_left"] = love.graphics.newQuad(0, 144, 64, 48, iw, ih)
   quad["bottom_right"] = love.graphics.newQuad(208, 144, 56, 48, iw, ih)
   quad["top_mid"] = {}
   quad["bottom_mid"] = {}
   for i=0,18 do
      table.insert(quad["top_mid"], love.graphics.newQuad(i * 8 + 36, 0, 8, 48, iw, ih))
      table.insert(quad["bottom_mid"], love.graphics.newQuad(i * 8 + 54, 144, 8, 48, iw, ih))
   end

   quad["mid_left"] = {}
   quad["mid_mid"] = {}
   quad["mid_right"] = {}
   for j=0,12 do
      table.insert(quad["mid_left"], love.graphics.newQuad(0, j * 8 + 48, 64, 8, iw, ih))

      local it = {}
      for i=0,18 do
         table.insert(it, love.graphics.newQuad(i * 8 + 64, j * 8 + 48, 8, 8, iw, ih))
      end
      table.insert(quad["mid_mid"], it)

      table.insert(quad["mid_right"], love.graphics.newQuad(208, j * 8 + 48, 56, 8, iw, ih))
   end

   return { quad = quad, batch = love.graphics.newSpriteBatch(img, iw * ih) }

end

function Window:init(shadow)
   self.shadow = shadow or false
end

function Window:draw()
   Draw.image(self.data.batch)
end

function Window:relayout(x, y, width, height)
   self.data = self.data or init_data()
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.data.batch:clear()

   local x_inner = width + x - width % 8 - 64
   local y_inner = height + y - height % 8 - 64

   y_inner = math.max(y_inner, y + 14)

   if not self.shadow then
      self.data.batch:add(self.data.quad["top_left"], x, y)
   end
   self.data.batch:add(self.data.quad["top_right"], x_inner, y)
   self.data.batch:add(self.data.quad["bottom_left"], x, y_inner)
   self.data.batch:add(self.data.quad["bottom_right"], x_inner, y_inner)

   for dx=8, width / 8 - 8 - 1 do
      local tile = (dx - 8) % 18 + 1
      if not self.shadow then
         self.data.batch:add(self.data.quad["top_mid"][tile], dx * 8 + x, y)
      end
      self.data.batch:add(self.data.quad["bottom_mid"][tile], dx * 8 + x, y_inner)
   end

   for dy=0, height / 8 - 14 do
      local tile_y = dy % 12 + 1
      if not self.shadow then
         self.data.batch:add(self.data.quad["mid_left"][tile_y], x, dy * 8 + y + 48)

         for dx=1, width / 8 - 15 do
            local tile_x = (dx - 8) % 18 + 1
            self.data.batch:add(self.data.quad["mid_mid"][tile_y][tile_x], dx * 8 + x + 56, dy * 8 + y + 48)
         end
      end
      self.data.batch:add(self.data.quad["mid_right"][tile_y], x_inner, dy * 8 + y + 48)
   end

   self.data.batch:flush()
end

function Window:update()
end

return Window
