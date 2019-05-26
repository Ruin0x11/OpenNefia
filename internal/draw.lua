local draw = {}

function draw.set_font(filename, size)
   love.graphics.setFont(love.graphics.newFont(filename, size, "mono"))
end

function draw.set_color(r, g, b)
   love.graphics.setColor(r, g, b)
end

function draw.set_background_color(r, g, b)
   love.graphics.setBackgroundColor(r, g, b)
end

function draw.text(str, x, y, color)
   if color then
      draw.set_color(color[1], color[2], color[3])
   end
   love.graphics.print(str, x, y)
end

function draw.load_image(filename)
   return love.graphics.newImage(filename)
end

function draw.image(image, x, y)
   return love.graphics.draw(image, x, y)
end

return draw
