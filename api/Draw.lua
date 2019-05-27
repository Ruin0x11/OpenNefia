local draw = require("internal.draw")

local Draw = {}

Draw.get_width = draw.get_width
Draw.get_height = draw.get_height
Draw.set_font = draw.set_font
Draw.set_color = draw.set_color
Draw.load_image = draw.load_image
Draw.text_width = draw.text_width
Draw.text_height = draw.text_height
Draw.text = draw.text
Draw.filled_rect = draw.filled_rect
Draw.image = draw.image
Draw.image_region = draw.image_region
Draw.image_stretched = draw.image_stretched
Draw.image_region_stretched = draw.image_region_stretched
Draw.line = draw.line

function Draw.text_shadowed(str, x, y, color, shadow_color)
   Draw.set_color(shadow_color[1], shadow_color[2], shadow_color[3], shadow_color[4])
   for dx=-1,1 do
      for dy=-1,1 do
         Draw.text(str, x + dx, y + dy)
      end
   end
   Draw.text(str, x, y, color)
end

return Draw
