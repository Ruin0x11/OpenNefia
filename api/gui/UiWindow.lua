local Draw = require("api.Draw")

local Window = require("api.gui.Window")
local TopicWindow = require("api.gui.TopicWindow")

local UiWindow = {}
local UiWindow_mt = { __index = UiWindow }

function UiWindow:new(x, y, width, height, shadow, title)
   local w = {
      x = x,
      y = y,
      width = width,
      height = height,
      title = title
   }

   if shadow then
      w.shadow = Window:new(x + 4, y + 4, width, height - height % 8)
   end

   if string.nonempty(title) then
      w.title_win = TopicWindow:new(x + 34, y - 4, 45 * width / 100 + math.clamp(Draw.string_width(title) - 120, 0, 200))
   end

   w.image = Window:new(x, y, width, height)

   setmetatable(w, UiWindow_mt)
   return w
end

function UiWindow:draw()
   if self.shadow then
      Draw.set_color(31, 31, 31, 127)
      self.shadow:draw()
   end
   Draw.set_color(255, 255, 255)
   self.image:draw()
   if self.topic_window then
      self.topic_window:draw()
   end
end

function UiWindow:update()
   if self.shadow then
      self.shadow:update()
   end
   self.image:update()
   if self.topic_window then
      self.topic_window:update()
   end
end

return UiWindow
