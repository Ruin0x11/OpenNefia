local Draw = require("api.Draw")

local Ui = {}

function Ui.params_centered(width, height, in_game)
   local x = (Draw.get_width() - width) / 2

   local y
   if in_game then
      y = 0
   else
      y = (Draw.get_height() - height) / 2
   end

   return x, y, width, height
end

local topic_quad
function Ui.draw_topic(topic, x, y)
   local icons = Draw.load_image("graphic/temp/tip_icons.bmp")
   topic_quad = topic_quad or love.graphics.newQuad(24, 0, 24, 16, icons:getWidth(), icons:getHeight())
   Draw.set_font(12, "bold")
   Draw.set_color(255, 255, 255)
   Draw.image_region(icons, topic_quad, x, y + 7)
   Draw.set_color(0, 0, 0)
   Draw.text(topic, x + 26, y + 8) -- y + vfix + 8
   Draw.line(x + 22, y + 21, x + Draw.text_width(topic) + 36, y + 21)
   Draw.set_color(255, 255, 255)
end

return Ui
