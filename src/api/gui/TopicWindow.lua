local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local UiTheme = require("api.gui.UiTheme")

local TopicWindow = class.class("TopicWindow", IUiElement)

function TopicWindow:init(frame_style, fill_style)
   self.frame_style = frame_style or 0
   self.fill_style = fill_style or 0
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

   self.i_topic_window = self.t.base["window_" .. self.frame_style]:make_instance(self.width, self.height)
   self.i_window = self.t.base.window:make_instance()

   self:update_batch()
end

function TopicWindow:update_batch()
   local x = self.x
   local y = self.y
   local width = self.width
   local height = self.height

   local parts = {}
   for i=0, width / 16 - 2 do
      parts[#parts+1] = { "top_mid", i * 16 + 16, 0 }
      parts[#parts+1] = { "bottom_mid", i * 16 + 16, height - 16 }
   end

   local x_inner = width / 16 * 16 - 16
   local y_inner = height / 16 * 16 - 16

   parts[#parts+1] = { "top_mid2", x_inner, 0 }
   parts[#parts+1] = { "bottom_mid2", x_inner, height - 16 }

   for i=0, height / 16 - 2 do
      parts[#parts+1] = { "left_mid", 0, i * 16 + 16 }
      parts[#parts+1] = { "right_mid", width - 16, i * 16 + 16 }
   end

   parts[#parts+1] = { "left_mid2", 0, y_inner }
   parts[#parts+1] = { "right_mid2", width - 16, y_inner }

   parts[#parts+1] = { "top_left", 0, 0 }
   parts[#parts+1] = { "bottom_left", 0, height - 16 }
   parts[#parts+1] = { "top_right", width - 16, 0 }
   parts[#parts+1] = { "bottom_right", width - 16, height - 16 }

   self.batch = self.i_topic_window:make_batch(parts)
end

function TopicWindow:draw()
   local x = self.x
   local y = self.y
   local width = self.width
   local height = self.height
   local fill_style = self.fill_style

   if fill_style == 6 then
      Draw.set_color(255, 255, 255, 180)
      Draw.image(self.batch, x + width / 2, y + height / 2, width - 4, height - 4)
   elseif fill_style < 5 then
      local rect = true
      if fill_style == 0 then
         Draw.set_color(255, 255, 255)
         rect = false
      elseif fill_style == 1 then
         Draw.set_color(255-195, 255-205, 255-195)
      elseif fill_style == 2 then
         Draw.set_color(255-210, 255-215, 255-205)
      elseif fill_style == 3 then
         Draw.set_color(255-10, 255-13, 255-16)
      elseif fill_style == 4 then
         Draw.set_color(255-195, 255-205, 255-195)
      else
         Draw.set_color(255, 255, 255)
      end
      -- if rect then
      --    Draw.filled_rect(x + 4, y + 4, width - 4, height - 4, )
      -- end
   end

   self.i_window:draw_region("fill", x + 4, y + 4, width - 6, height - 8)

   Draw.set_color(255, 255, 255, 255)
   Draw.image(self.batch, x, y)

   if fill_style == 5 then
      Draw.image(self.batch, x + 2, x + 2, width - 4, height - 5, {255-195, 255-205, 255-195})

      Draw.set_blend_mode("subtract")
      Draw.set_color(195, 205, 195)
      Draw.filled_rect(x + 2, y + 2, width - 4, height - 5)
      Draw.set_blend_mode("alpha")
   end
end

function TopicWindow:update()
end

return TopicWindow
