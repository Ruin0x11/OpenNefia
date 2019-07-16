local draw = require("internal.draw")

-- Functions for drawing things on the screen.
-- @module Draw
local Draw = {}

Draw.layer_count = draw.layer_count
Draw.get_layer = draw.get_layer
Draw.set_root = draw.set_root
Draw.get_coords = draw.get_coords
Draw.get_tiled_width = draw.get_tiled_width
Draw.get_tiled_height = draw.get_tiled_height
Draw.with_canvas = draw.with_canvas
Draw.set_font = draw.set_font

-- TODO remove
Draw.load_image = draw.load_image

Draw.get_width = love.graphics.getWidth
Draw.get_height = love.graphics.getHeight
Draw.create_canvas = love.graphics.newCanvas

function Draw.set_color(r, g, b, a)
   if type(r) == "table" then
      love.graphics.setColor(
         r[1] / 255,
         r[2] / 255,
         r[3] / 255,
         (r[4] or 255) / 255)
   else
      love.graphics.setColor(
         r / 255,
         g / 255,
         b / 255,
         (a or 255) / 255)
   end
end

function Draw.set_background_color(r, g, b, a)
   love.graphics.setBackgroundColor(r, g, b, a)
end

Draw.clear = love.graphics.clear

function Draw.text(str, x, y, color, size)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   if size then
      Draw.set_font(size)
   end
   love.graphics.print(str, x, y)
end

function Draw.filled_rect(x, y, width, height, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.polygon("fill", x, y, x + width, y, x + width, y + height, x, y + height)
end

function Draw.line_rect(x, y, width, height, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.polygon("line", x, y, x + width, y, x + width, y + height, x, y + height)
end

function Draw.line(x1, y1, x2, y2, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.line(x1, y1 + 1, x2, y2 + 1)
end

function Draw.text_width(text, size)
   if size then
      Draw.set_font(size)
   end
   return love.graphics.getFont():getWidth(text)
end

function Draw.text_height()
   return love.graphics.getFont():getHeight()
end

function Draw.wrap_text(text, wraplimit)
   return love.graphics.getFont():getWrap(text, wraplimit)
end

function Draw.image(image, x, y, width, height, color, centered, rotation)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   if width then
      sx = width / image:getWidth()
   end
   if height then
      sy = height / image:getHeight()
   end
   local ox, oy
   if centered then
      ox = (image:getWidth()) / 2
      oy = (image:getHeight()) / 2
   end
   return love.graphics.draw(image, x, y, rotation or 0, sx, sy, ox, oy)
end

function Draw.image_region(image, quad, x, y, width, height, color, centered, rotation)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   local _, _, qw, qh = quad:getViewport()
   if width then
      sx = width / qw
   end
   if height then
      sy = height / qh
   end
   local ox, oy
   if centered then
      ox = (width or qw) / 2
      oy = (width or qh) / 2
   end
   return love.graphics.draw(image, quad, x, y, 0, sx, sy, ox, oy)
end

function Draw.image_stretched(image, x, y, tx, ty, color, rotation)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   if tx and ty then
      sx = (tx - x) / image:getWidth()
      sy = (ty - y) / image:getHeight()
   end
   return love.graphics.draw(image, x, y, 0, sx, sy)
end

function Draw.image_region_stretched(image, quad, x, y, tx, ty, color, rotation)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   local _, _, qw, qh = quad:getViewport()
   if tx and ty then
      sx = (tx - x) / qw
      sy = (ty - y) / qh
   end
   return love.graphics.draw(image, quad, x, y, 0, sx, sy)
end

local framerate = 20

function Draw.wait(msecs)
   local msecs_per_frame = (1 / framerate) * 1000
   local frames = msecs / msecs_per_frame
   love.timer.sleep(frames / 1000)
end

function Draw.add_async_callback(cb)
   if type(cb) ~= "function" then
      error("Callback must be a function.")
   end

   local field = require("game.field")
   if not field.is_active then
      error("Must be in-game.")
   end

   field:add_async_draw_callback(cb)
end

-- TODO: sanitize
Draw.yield = coroutine.yield

function Draw.text_shadowed(str, x, y, color, shadow_color)
   color = color or {255, 255, 255}
   shadow_color = shadow_color or {0, 0, 0}
   Draw.set_color(shadow_color[1], shadow_color[2], shadow_color[3], shadow_color[4])
   for dx=-1,1 do
      for dy=-1,1 do
         Draw.text(str, x + dx, y + dy)
      end
   end
   Draw.text(str, x, y, color)
end

-- HACK: Needs to be replaced with resource system.
function Draw.register_draw_layer(layer)
   local field = require("game.field")
   field:register_draw_layer(layer)
end

function Draw.msecs_to_frames(msecs, framerate)
   framerate = framerate or 60
   local msecs_per_frame = (1 / framerate or 60) * 1000
   local frames = msecs / msecs_per_frame
   return frames
end

return Draw
