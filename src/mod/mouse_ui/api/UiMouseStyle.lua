local Draw = require("api.Draw")
local UiMousePadding = require("mod.mouse_ui.api.gui.UiMousePadding")
local UiMouseFit = require("mod.mouse_ui.api.gui.UiMouseFit")

local UiMouseStyle = {}

function UiMouseStyle.draw_vertical_line(x, y1, y2, color_dark, color_light)
   Draw.set_color(color_dark)
   Draw.line(x, y1, x, y2)
   Draw.set_color(color_light)
   Draw.line(x+1, y1, x+1, y2)
end

function UiMouseStyle.draw_panel(x, y, width, height, thickness, pressed, color, color_dark, color_light)
   Draw.set_color(color)
   Draw.filled_rect(x, y, width-1, height-1)

   if pressed then
      Draw.set_color(color_dark)
   else
      Draw.set_color(color_light)
   end
   for i = 0, thickness - 1 do
      Draw.line(x, y + i, x + width - i - thickness, y + i)
      Draw.line(x + i, y - 1, x + i, y + height - i - thickness)
   end

   if pressed then
      Draw.set_color(color_light)
   else
      Draw.set_color(color_dark)
   end
   for i = 0, thickness - 1 do
      Draw.line(x + (thickness - i - 1), y + height + i - thickness, x + width - (thickness - i), y + height + i - thickness)
      Draw.line(x + width + i - thickness, y + (thickness - i - 1), x + width + i - thickness, y + height - (thickness - i))
   end
end

function UiMouseStyle.default_padding()
   return UiMousePadding:new_all(1)
end

function UiMouseStyle.default_fit()
   return UiMouseFit.none
end

return UiMouseStyle
