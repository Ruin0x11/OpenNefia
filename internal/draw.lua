local draw = {}

local width = 800
local height = 600

local canvas = nil

--
--
-- Internal engine functions
--
--

local function create_canvas(w, h)
   canvas = love.graphics.newCanvas(w, h)

   love.graphics.setCanvas(canvas)

   love.graphics.clear()
   love.graphics.setBlendMode("alpha")

   love.graphics.setCanvas()

   return canvas
end

function draw.init()
   love.window.setTitle("Elona_next")
   local success = love.window.setMode(width, height, {})
   if not success then
      error("Could not initialize display.")
   end

   canvas = create_canvas(width, height)
end

function draw.draw()
   love.graphics.setCanvas(canvas)
   love.graphics.clear()
end

function draw.draw_end()
   love.graphics.setCanvas()

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.setBlendMode("alpha", "premultiplied")

   love.graphics.draw(canvas)

   love.graphics.setBlendMode("alpha")
end

--
--
-- Event callbacks
--
--

function draw.resize(w, h)
   canvas = create_canvas(w, h)
end

--
--
-- API functions
--
--

draw.get_width = love.graphics.getWidth
draw.get_height = love.graphics.getHeight

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

function draw.image(image, x, y, tx, ty)
   local sx = 1
   local sy = 1
   if tx and ty then
      sx = (tx - x) / image:getWidth()
      sy = (ty - y) / image:getHeight()
   end
   return love.graphics.draw(image, x, y, 0, sx, sy)
end


return draw
