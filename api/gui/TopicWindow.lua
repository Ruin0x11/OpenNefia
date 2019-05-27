local Draw = require("api.Draw")

local TopicWindow = {}
local TopicWindow_mt = { __index = TopicWindow }

function TopicWindow:new(x, y, width, height, shadow, frame_style, fill_style)
   local w = {
      x = x,
      y = y,
      width = math.max(width, 32),
      height = math.max(height, 24),
      frame_style = frame_style,
      fill_style = fill_style,
   }

   setmetatable(w, TopicWindow_mt)
   return w
end

function TopicWindow:draw()
end

function TopicWindow:update()
end

return TopicWindow
