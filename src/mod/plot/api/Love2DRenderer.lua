local Draw = require("api.Draw")
local IPlotRenderer = require("mod.plot.api.IPlotRenderer")

local Love2DRenderer = class.class("Love2DRenderer", IPlotRenderer)

function Love2DRenderer:init()
   -- self.bezier = Draw.make_bezier_curve(0, 0, 0, 0, 0, 0, 0, 0)
end

function Love2DRenderer:draw_path(ctx, path, transform, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   else
      Draw.set_color(0, 0, 0)
   end

   local x, y = transform:transform(path.vertices[1][1], path.vertices[1][2])

   for _, vertex, cmd in path:iter() do
      local tx, ty = transform:transform(vertex[1], vertex[2])
      if cmd == "move_to" then
         x = tx
         y = ty
      elseif cmd == "line_to" then
         Draw.line(x, y, tx, ty)
         x = tx
         y = ty
--[[
      elseif cmd == "bezier_quad" then
         if skip == 0 then
            skip = 1
            self.bezier:setControlPoint(1, x, y)
            x = tx
            y = ty
         else
            self.bezier:setControlPoint(3-skip, x, y)
            skip = skip - 1
            if skip == 0 then
               self.bezier:setControlPoint(3, tx, ty)
               self.bezier:removeControlPoint(4)
               Draw.line(self.bezier:render())
            end
            x = tx
            y = ty
         end
--]]
      end
   end
end

function Love2DRenderer:draw_text(ctx, s, x, y, size, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   else
      Draw.set_color(0, 0, 0)
   end

   Draw.set_font(size)
   Draw.text(s, x, y)
end

function Love2DRenderer:get_text_width_height_descent(ctx, s, size, properties)
   Draw.set_font(size)
   return Draw.text_width(s), Draw.text_height(), 0
end

function Love2DRenderer:draw_marker(ctx, x, y, radius, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   else
      Draw.set_color(0, 0, 0)
   end

   Draw.line_rect(x - 10, y - 10, 20, 20)
end

return Love2DRenderer
