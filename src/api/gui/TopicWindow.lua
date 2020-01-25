local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local UiTheme = require("api.gui.UiTheme")

local TopicWindow = class.class("TopicWindow", IUiElement)

function TopicWindow:init(frame_style, fill_style)
   self.frame_style = frame_style
   self.fill_style = fill_style
end

function TopicWindow:relayout(x, y, width, height)
   width = math.max(width, 32)
   height = math.max(height, 24)

   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   Draw.set_color(255, 255, 255)

   local parts = {}
   for i=0, width / 16 - 2 do
      parts[#parts+1] = { "top_mid", i * 16 + x + 16, y }
      parts[#parts+1] = { "bottom_mid", i * 16 + x + 16, y + height - 16 }
   end

   local x_inner = x + width / 16 * 16 - 16
   local y_inner = y + height / 16 * 16 - 16

   parts[#parts+1] = { "top_mid2", x_inner, y }
   parts[#parts+1] = { "bottom_mid2", x_inner, y + height - 16 }

   for i=0, height / 16 - 2 do
      parts[#parts+1] = { "left_mid", x, i * 16 + y + 16 }
      parts[#parts+1] = { "right_mid", x + width - 16, i * 16 + y + 16 }
   end

   parts[#parts+1] = { "left_mid2", x, y_inner }
   parts[#parts+1] = { "right_mid2", x + width - 16, y_inner }

   parts[#parts+1] = { "top_left", x, y }
   parts[#parts+1] = { "bottom_left", x, y + height - 16 }
   parts[#parts+1] = { "top_right", x + width - 16, y }
   parts[#parts+1] = { "bottom_right", x + width - 16, y + height - 16 }

   self.batch = self.t["window_" .. self.frame_style]:make_batch(parts, self.width, self.height)
end

function TopicWindow:draw()
   local x = self.x
   local y = self.y
   local width = self.width
   local height = self.height
   local fill_style = self.fill_style
   local color = {255, 255, 255}

   if fill_style == 6 then
      Draw.image(self.batch, x + width / 2, y + height / 2, width - 4, height - 4, {255, 255, 255, 180})
   elseif fill_style < 5 then
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

      self.t.window:draw_region("fill", x + 4, y + 4, width - 6, height - 8, color)
      -- if rect then
      --    Draw.filled_rect(x + 4, y + 4, width - 4, height - 4, )
      -- end
   end

   Draw.set_color(255, 255, 255, 255)
   Draw.image(self.batch)

   if fill_style == 5 then
      Draw.image(self.batch, x + 2, y + 2, width - 4, height - 5, {255-195, 255-205, 255-195})
      -- Draw.filled_rect(x + 2, y + 2, width - 4, height - 5, {255-195, 255-205, 255-195})
   end
end

function TopicWindow:update()
end

return TopicWindow
