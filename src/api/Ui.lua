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

local topic_icon
function Ui.draw_topic(topic, x, y)
   topic_icon = topic_icon or Draw.load_image("graphic/temp/topic_icon.bmp")
   Draw.set_font(12, "bold")
   Draw.image(topic_icon, x, y + 7)
   Draw.text(topic, x + 26, y + 8) -- y + vfix + 8
   Draw.line(x + 22, y + 21, x + Draw.text_width(topic) + 36, y + 21)
end

return Ui
